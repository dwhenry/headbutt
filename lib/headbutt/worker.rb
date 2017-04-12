# frozen_string_literal: true
require 'headbutt/core_ext'

module Headbutt

  ##
  # Include this module in your worker class and you can easily create
  # asynchronous jobs:
  #
  # class HardWorker
  #   include Sidekiq::Worker
  #
  #   def perform(*args)
  #     # do some work
  #   end
  # end
  #
  # Then in your Rails app, you can do this:
  #
  #   HardWorker.perform_async(1, 2, 3)
  #
  # Note that perform_async is a class method, perform is an instance method.
  module Worker
    attr_accessor :jid

    def self.included(base)
      raise ArgumentError, "You cannot include Headbutt::Worker in an ActiveJob: #{base.name}" if base.ancestors.any? {|c| c.name == 'ActiveJob::Base' }

      base.extend(ClassMethods)
      base.class_attribute :headbutt_options_hash
      base.class_attribute :headbutt_retry_in_block
      base.class_attribute :headbutt_retries_exhausted_block
    end

    def logger
      Headbutt.logger
    end

    module ClassMethods
      
      def set(options)
        Thread.current[:headbutt_worker_set] = options
        self
      end

      def perform_async(*args)
        client_push('class' => self, 'args' => args)
      end

      # +interval+ must be a timestamp, numeric or something that acts
      #   numeric (like an activesupport time interval).
      def perform_in(interval, *args)
        int = interval.to_f
        now = Time.now.to_f
        ts = (int < 1_000_000_000 ? now + int : int)

        item = { 'class' => self, 'args' => args, 'at' => ts }

        # Optimization to enqueue something now that is scheduled to go out now or in the past
        item.delete('at'.freeze) if ts <= now

        client_push(item)
      end
      alias_method :perform_at, :perform_in

      ##
      # Allows customization for this type of Worker.
      # Legal options:
      #
      #   queue - use a named queue for this Worker, default 'default'
      #   retry - enable the RetryJobs middleware for this Worker, *true* to use the default
      #      or *Integer* count
      #   backtrace - whether to save any error backtrace in the retry payload to display in web UI,
      #      can be true, false or an integer number of lines to save, default *false*
      #   pool - use the given Redis connection pool to push this type of job to a given shard.
      #
      # In practice, any option is allowed.  This is the main mechanism to configure the
      # options for a specific job.
      def headbutt_options(opts={})
        self.headbutt_options_hash = get_headbutt_options.merge(opts.stringify_keys)
      end

      def headbutt_retry_in(&block)
        self.headbutt_retry_in_block = block
      end

      def headbutt_retries_exhausted(&block)
        self.headbutt_retries_exhausted_block = block
      end

      def get_headbutt_options # :nodoc:
        self.headbutt_options_hash ||= Headbutt.default_worker_options
      end

      def client_push(item) # :nodoc:
        job = item.merge(
          jid: SecureRandom.uuid,
          created_at: Time.now.to_f,
        ).stringify_keys
        Headbutt::BunnyManager.instance.task_queue.push job
      end
    end
  end
end
