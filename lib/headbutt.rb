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
require 'headbutt/runner'
require 'headbutt/version'
