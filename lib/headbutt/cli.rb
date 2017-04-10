require 'headbutt'
require 'headbutt/cli/banner'
require 'headbutt/cli/option_parser'
require 'headbutt/cli/trapper'
require 'headbutt/util'

module Headbutt
  class CLI
    include Headbutt::Util

    def initialize(args=ARGV, runner: Headbutt::Runner, trapper: Headbutt::Trapper)
      @runner_klass = runner
      @trapper_klass = trapper
      setup_options(args)
      Headbutt::Banner.print
      initialize_logger
    end

    def run
      daemonize if options[:daemon]
      write_pid

      @runner = @runner_klass.new(options)
      @runner = @trapper_klass.new(@runner) if @trapper_klass # allow trapper to be disabled in testing

      @runner.start
    end

    def setup_options(args)
      opts = OptionParser.parse(args)

      set_environment opts[:environment]

      # cfile = opts[:config_file]
      # opts = parse_config(cfile).merge(opts) if cfile

      opts[:strict] = true if opts[:strict].nil?
      # opts[:concurrency] = Integer(ENV["RAILS_MAX_THREADS"]) if !opts[:concurrency] && ENV["RAILS_MAX_THREADS"]
      opts[:identity] = identity

      options.merge!(opts)
    end

    def options
      @options ||= Headbutt.options
    end

    def set_environment(cli_env)
      @environment = cli_env || ENV['RAILS_ENV'] || ENV['RACK_ENV'] || 'development'
    end

    def daemonize
      raise ArgumentError, "You really should set a logfile if you're going to daemonize" unless options[:logfile]
      files_to_reopen = []
      ObjectSpace.each_object(File) do |file|
        files_to_reopen << file unless file.closed?
      end

      ::Process.daemon(true, true)

      files_to_reopen.each do |file|
        begin
          file.reopen file.path, "a+"
          file.sync = true
        rescue ::Exception
        end
      end

      [$stdout, $stderr].each do |io|
        File.open(options[:logfile], 'ab') do |f|
          io.reopen(f)
        end
        io.sync = true
      end
      $stdin.reopen('/dev/null')

      initialize_logger
    end

    def initialize_logger
      Headbutt::Logging.initialize_logger(options[:logfile]) if options[:logfile]

      Headbutt.logger.level = ::Logger::DEBUG if options[:verbose]
    end

    def write_pid
      if path = options[:pidfile]
        pidfile = File.expand_path(path)
        File.open(pidfile, 'w') do |f|
          f.puts ::Process.pid
        end
      end
    end
  end
end
