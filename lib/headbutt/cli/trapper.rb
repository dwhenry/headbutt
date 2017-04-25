module Headbutt
  class Trapper
    def initialize(runner)
      @runner = runner
    end

    def start
      self_read, self_write = IO.pipe

      %w(INT TERM USR1 USR2 TTIN).each do |sig|
        begin
          trap sig do
            self_write.puts(sig)
          end
        rescue ArgumentError
          puts "Signal #{sig} not supported"
        end
      end

      @runner.init if @runner.respond_to?(:init)

      begin
        @runner.start

        while (readable_io = IO.select([self_read]))
          signal = readable_io.first[0].gets.strip
          handle_signal(signal)
        end
      rescue Interrupt
        Headbutt.logger.info 'Shutting down'
        @runner.stop
        # Explicitly exit so busy Processor threads can't block
        # process shutdown.
        Headbutt.logger.info 'Bye!'
        exit(0)
      end
    end

    def handle_signal(sig)
      Headbutt.logger.debug "Got #{sig} signal"
      case sig
      when 'INT'
        # Handle Ctrl-C in JRuby like MRI
        # http://jira.codehaus.org/browse/JRUBY-4637
        raise Interrupt
      when 'TERM'
        # Heroku sends TERM and then waits 10 seconds for process to exit.
        raise Interrupt
      when 'USR1'
        Headbutt.logger.info 'Received USR1, no longer accepting new work'
        @runner.quiet
      when 'USR2'
        if Headbutt.options[:logfile]
          Headbutt.logger.info 'Received USR2, reopening log file'
          Headbutt::Logging.reopen_logs
        end
      when 'TTIN'
        Thread.list.each do |thread|
          Headbutt.logger.warn "Thread TID-#{thread.object_id.to_s(36)} #{thread['label']}"
          if thread.backtrace
            Headbutt.logger.warn thread.backtrace.join("\n")
          else
            Headbutt.logger.warn '<no backtrace available>'
          end
        end
      end
    end
  end
end
