module Headbutt
  class Runner
    def initialize(options)
      @manager = Sidekiq::Manager.new(options)
      # @poller = Sidekiq::Scheduled::Poller.new
      @done = false
      @options = options
    end

    def start
      # @thread = safe_thread("heartbeat", &method(:start_heartbeat))
      # @poller.start

      # start required number of works to do background tasks
      # these are identified as haveing a maessage in the format "<app-name>.task.<task-class>"
      # these should be treated in the same way to sidekiq tasks
      @manager.start

      # start things watching the custom queues - this is for more advanced things like msg bus implementation
    end

    # Stops this instance from processing any more jobs,
    #
    def quiet
      @done = true
      @manager.quiet
      # @poller.terminate
    end

    # Shuts down the process.  This method does not
    # return until all work is complete and cleaned up.
    # It can take up to the timeout to complete.
    def stop
      deadline = Time.now.to_f + @options[:timeout]

      @done = true
      @manager.quiet
      # @poller.terminate

      @manager.stop(deadline)

      # clear_heartbeat
    end

    def stopping?
      @done
    end
  end
end
