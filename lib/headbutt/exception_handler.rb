# frozen_string_literal: true
require 'headbutt'

module Headbutt
  module ExceptionHandler
    class Logger
      def call(ex, ctx_hash)
        Headbutt.logger.warn(Headbutt.dump_json(ctx_hash)) unless ctx_hash.empty?
        Headbutt.logger.warn "#{ex.class.name}: #{ex.message}"
        Headbutt.logger.warn ex.backtrace.join("\n") unless ex.backtrace.nil?
      end

      # Set up default handler which just logs the error
      Headbutt.error_handlers << Headbutt::ExceptionHandler::Logger.new
    end

    def handle_exception(ex, ctxHash = {})
      Headbutt.error_handlers.each do |handler|
        begin
          handler.call(ex, ctxHash)
        rescue => ex
          Headbutt.logger.error '!!! ERROR HANDLER THREW AN ERROR !!!'
          Headbutt.logger.error ex
          Headbutt.logger.error ex.backtrace.join("\n") unless ex.backtrace.nil?
        end
      end
    end
  end
end
