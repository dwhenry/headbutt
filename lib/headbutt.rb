require 'headbutt/logging'
require 'headbutt/manager'
require 'headbutt/processor'
require 'headbutt/runner'
require 'headbutt/util'
require 'headbutt/version'

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
end
