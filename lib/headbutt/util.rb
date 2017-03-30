# frozen_string_literal: true

# This case has been copied in it's entirety from the `sidekiq` gem
require 'socket'
require 'securerandom'
require 'headbutt/exception_handler'
# require 'sidekiq/core_ext'

module Headbutt
  ##
  # This module is part of Sidekiq core and not intended for extensions.
  #
  module Util
    include Headbutt::ExceptionHandler

    EXPIRY = 60 * 60 * 24

    def watchdog(last_words)
      yield
    rescue Exception => ex
      handle_exception(ex, { context: last_words })
      raise ex
    end

    def safe_thread(name, &block)
      Thread.new do
        watchdog(name, &block)
      end
    end

    # def logger
    #   Sidekiq.logger
    # end
    #
    # def redis(&block)
    #   Sidekiq.redis(&block)
    # end

    def hostname
      ENV['DYNO'] || Socket.gethostname
    end

    def process_nonce
      @@process_nonce ||= SecureRandom.hex(6)
    end

    def identity
      @@identity ||= "#{hostname}:#{$$}:#{process_nonce}"
    end

    def fire_event(event, reverse=false)
      arr = Headbutt.options[:lifecycle_events][event]
      arr.reverse! if reverse
      arr.each do |block|
        begin
          block.call
        rescue => ex
          handle_exception(ex, { context: "Exception during Sidekiq lifecycle event.", event: event })
        end
      end
      arr.clear
    end
  end
end
