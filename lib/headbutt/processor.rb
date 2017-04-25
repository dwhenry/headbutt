require "bunny" # don't forget to put gem "bunny" in your Gemfile

module Headbutt
  class Processor
    include Headbutt::Util

    def start
      @thread ||= safe_thread("processor") { run }
    end

    def terminate
      @done = true
    end

    def kill

    end

    def run
      begin
        process_loop
        @mgr.processor_stopped(self)
      rescue Sidekiq::Shutdown
        @mgr.processor_stopped(self)
      rescue Exception => ex
        @mgr.processor_died(self, ex)
      end
    end

    def process_loop
      manager = BunnyManager.instance

      manager.task_queue.subscribe(block: true, manual_ack: true) do |delivery_info, properties, payload|
        ack = false
        begin
          process(payload)
          ack = true

          return if @done
        rescue Headbutt::Shutdown
          ack = false
        ensure
          if ack
            manager.ack(delivery_info.delivery_tag)
          else
            # tell rabbitmq to requeue teh message so we can try to process it again.
            manager.nack(delivery_info.delivery_tag, false, true)
          end
        end
      end
    end

    def process(payload)
      job_hash = Headbutt.load_json(payload)

      klass  = job_hash['class'.freeze].constantize
      worker = klass.new
      worker.jid = job_hash['jid'.freeze]

      Headbutt::Stats(worker, job_hash) do
        Headbutt.server_middleware.invoke(worker, job_hash, BunnyRetry.new) do
          args = job_hash['args'.freeze]
          worker.perform(*args)
        end
      end
    rescue Headbutt::Shutdown
      # Had to force kill this job because it didn't finish
      # within the timeout.
      raise
    rescue Exception => ex
      # ack if any error other than Shutdown as it would be requeued if required
      handle_exception(ex, { :context => "Job raised exception", :job => job_hash, :jobstr => payload })
      raise
    end
  end

  class BunnyRetry
    def initialize(manager = BunnyManager.instance)
      @manager = manager
    end

    def retry(job, expiration)
      @manager.task_retry_queue.publish(job, expiration: expiration)
    end

    def expire(job)

    end
  end
end
