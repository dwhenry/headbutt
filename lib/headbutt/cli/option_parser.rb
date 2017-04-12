require 'optparse'

module Headbutt
  class OptionParser
    def self.parse(argv)
      opts = {}

      parser = ::OptionParser.new do |o|
        # o.on '-c', '--concurrency INT', "processor threads to use" do |arg|
        #   opts[:concurrency] = Integer(arg)
        # end

        o.on '-d', '--daemon', "Daemonize process" do |arg|
          opts[:daemon] = arg
        end

        o.on '-e', '--environment ENV', "Application environment" do |arg|
          opts[:environment] = arg
        end

        o.on '-g', '--tag TAG', "Process tag for procline" do |arg|
          opts[:tag] = arg
        end

        # o.on '-i', '--index INT', "unique process index on this machine" do |arg|
        #   opts[:index] = Integer(arg.match(/\d+/)[0])
        # end
        #
        # o.on "-q", "--queue QUEUE[,WEIGHT]", "Queues to process with optional weights" do |arg|
        #   queue, weight = arg.split(",")
        #   parse_queue opts, queue, weight
        # end

        o.on '-r', '--require [PATH|DIR]', "Location of Rails application with workers or file to require" do |arg|
          opts[:require] = arg
        end

        # o.on '-t', '--timeout NUM', "Shutdown timeout" do |arg|
        #   opts[:timeout] = Integer(arg)
        # end

        o.on "-v", "--verbose", "Print more verbose output" do |arg|
          opts[:verbose] = arg
        end

        # o.on '-C', '--config PATH', "path to YAML config file" do |arg|
        #   opts[:config_file] = arg
        # end

        # o.on '-L', '--logfile PATH', "path to writable logfile" do |arg|
        #   opts[:logfile] = arg
        # end

        o.on '-P', '--pidfile PATH', "path to pidfile" do |arg|
          opts[:pidfile] = arg
        end

        o.on '-V', '--version', "Print version and exit" do |arg|
          puts "Headbutt #{Headbutt::VERSION}"
          exit(0)
        end
      end

      parser.banner = "sidekiq [options]"
      # parser.on_tail "-h", "--help", "Show help" do
      #   logger.info parser
      #   exit 1
      # end
      parser.parse!(argv)

      # %w[config/sidekiq.yml config/sidekiq.yml.erb].each do |filename|
      #   opts[:config_file] ||= filename if File.exist?(filename)
      # end

      opts
    end
  end
end
