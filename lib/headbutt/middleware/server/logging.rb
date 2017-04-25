module Headbutt
  module Middleware
    module Server
      class Logging

        def call(worker, job, _retry_manager)
          Headbutt::Logging.with_context(log_context(worker, job)) do
            begin
              start = Time.now.to_f
              logger.info('start')
              yield
              logger.info("done: #{elapsed(start)} sec")
            rescue Exception
              logger.info("fail: #{elapsed(start)} sec")
              raise
            end
          end
        end

        private

        # If we're using a wrapper class, like ActiveJob, use the "wrapped"
        # attribute to expose the underlying thing.
        def log_context(worker, job)
          klass = job['wrapped'.freeze] || worker.class.to_s
          "#{klass} JID-#{job['jid'.freeze]}#{" BID-#{job['bid'.freeze]}" if job['bid'.freeze]}"
        end

        def elapsed(start)
          (Time.now.to_f - start).round(3)
        end

        def logger
          Headbutt.logger
        end
      end
    end
  end
end
