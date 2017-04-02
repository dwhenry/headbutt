module Headbutt
  class BunnyManager
    TASK_EXCHANGE = 'task_exchange'
    TASK_RETRY_EXCHANGE = 'task_retry_exchange'

    TASK_QUEUE = 'task_queue'
    TASK_RETRY_QUEUE = 'task_retry_queue'

    def self.instance
      @instance ||= new
    end

    def self.instance=(instance)
      @instance = instance
    end

    def initialize(connection = nil)
      @connection = connection
    end

    def connection
      @connection ||= Bunny.new(ENV['CLOUDAMQP_URL']).tap(&:start)
    end

    def ack(*args)
      channel.ack(*args)
    end

    def task_queue
      queue = channel.queue(TASK_QUEUE)
      queue.bind(task_exchange)
      queue
    end

    # This will be queue where will publish messages with TTL
    def task_retry_queue
      channel
        .queue(TASK_RETRY_QUEUE, arguments: { 'x-dead-letter-exchange': TASK_EXCHANGE })
        .bind(task_retry_exchange)
    end

    private

    def channel
      @channel ||= connection.create_channel
    end

    def task_exchange
      channel.fanout(TASK_EXCHANGE,  durable: true)
    end

    def task_retry_exchange
      channel.fanout(TASK_RETRY_EXCHANGE, durable: true)
    end
  end
end
