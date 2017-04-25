module Headbutt
  # Middleware is code configured to run before/after
  # a message is processed.  It is patterned after Rack
  # middleware. Middleware exists for the client side
  # (pushing jobs onto the queue) as well as the server
  # side (when jobs are actually processed).
  #
  # To add middleware for the client:
  #
  # Sidekiq.configure_client do |config|
  #   config.client_middleware do |chain|
  #     chain.add MyClientHook
  #   end
  # end
  #
  # To modify middleware for the server, just call
  # with another block:
  #
  # Sidekiq.configure_server do |config|
  #   config.server_middleware do |chain|
  #     chain.add MyServerHook
  #     chain.remove ActiveRecord
  #   end
  # end
  #
  # To insert immediately preceding another entry:
  #
  # Sidekiq.configure_client do |config|
  #   config.client_middleware do |chain|
  #     chain.insert_before ActiveRecord, MyClientHook
  #   end
  # end
  #
  # To insert immediately after another entry:
  #
  # Sidekiq.configure_client do |config|
  #   config.client_middleware do |chain|
  #     chain.insert_after ActiveRecord, MyClientHook
  #   end
  # end
  #
  # This is an example of a minimal server middleware:
  #
  # class MyServerHook
  #   def call(worker_instance, msg, queue)
  #     puts "Before work"
  #     yield
  #     puts "After work"
  #   end
  # end
  #
  # This is an example of a minimal client middleware, note
  # the method must return the result or the job will not push
  # to Redis:
  #
  # class MyClientHook
  #   def call(worker_class, msg, queue, redis_pool)
  #     puts "Before push"
  #     result = yield
  #     puts "After push"
  #     result
  #   end
  # end
  #
  module Middleware
    class Chain
      class NotFound < StandardError; end

      attr_reader :entries
      delegate :clear, to: :entries

      def initialize_copy(copy)
        copy.instance_variable_set(:@entries, entries.dup)
      end

      def initialize
        @entries = []
        yield self if block_given?
      end

      def remove(klass)
        entries.delete_if { |entry| entry.klass == klass }
      end

      def add(klass, *args)
        remove(klass)
        entries << Entry.new(klass, *args)
      end

      def prepend(klass, *args)
        remove(klass)
        entries.insert(0, Entry.new(klass, *args))
      end

      def insert_before(old_klass, new_klass, *args)
        remove(new_klass)
        i = entries.index { |entry| entry.klass == old_klass } || 0
        entries.insert(i, Entry.new(new_klass, *args))
      end

      def insert_after(old_klass, new_klass, *args)
        remove(new_klass)
        i = entries.index { |entry| entry.klass == old_klass } || entries.count - 1
        entries.insert(i + 1, Entry.new(new_klass, *args))
      end

      def invoke(*args, &block)
        CallChain.new(entries.map(&:make_new), *args, &block).call
      end

      class CallChain
        def initialize(chain, *args, &block)
          @chain = chain.dup
          @args = args
          @block = block
        end

        def call
          _callable
        end

        def _callable
          if @chain.empty?
            @block.call
          else
            @chain.shift.call(*@args, &method(:_callable))
          end
        end
      end
    end

    class Entry
      attr_reader :klass, :args

      def initialize(klass, *args)
        @klass = klass
        @args  = args
      end

      def make_new
        @klass.new(*@args)
      end
    end
  end
end
