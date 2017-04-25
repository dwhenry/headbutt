require 'headbutt/middleware/chain'

module Headbutt
  DEFAULTS = {
    error_handlers: [],
    lifecycle_events: {
      startup: [],
      quiet: [],
      shutdown: [],
      heartbeat: [],
    },
  }

  def self.options
    @options ||= DEFAULTS.dup
  end

  def self.load_json(string)
    JSON.parse(string)
  end

  def self.dump_json(object)
    JSON.generate(object)
  end

  def self.logger
    Headbutt::Logging.logger
  end

  def self.logger=(log)
    Headbutt::Logging.logger = log
  end

  def self.error_handlers
    self.options[:error_handlers]
  end

  def self.client_middleware
    @client_chain ||= Headbutt::Middleware::Chain.new
    yield @client_chain if block_given?
    @client_chain
  end

  def self.server_middleware
    @server_chain ||= default_server_middleware
    yield @server_chain if block_given?
    @server_chain
  end

  def self.default_server_middleware
    require 'headbutt/middleware/server/retry_jobs'
    require 'headbutt/middleware/server/logging'

    Headbutt::Middleware::Chain.new do |m|
      m.add Headbutt::Middleware::Server::Logging
      m.add Headbutt::Middleware::Server::RetryJobs
    end
  end

  # We are shutting down Headbutt but what about workers that
  # are working on some long job?  This error is
  # raised in workers that have not finished within the hard
  # timeout limit.  This is needed to rollback db transactions,
  # otherwise Ruby's Thread#kill will commit.
  class Shutdown < Interrupt; end
end

require 'json'
require 'headbutt/util'

require 'headbutt/bunny_manager'
require 'headbutt/core_ext'
require 'headbutt/logging'
require 'headbutt/manager'
require 'headbutt/processor'
require 'headbutt/stats'
require 'headbutt/runner'
require 'headbutt/version'
require 'headbutt/worker'

require 'headbutt/cli'
