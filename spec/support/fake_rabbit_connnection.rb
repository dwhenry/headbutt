require 'bunny-mock'

module FakeRabbitConnection
  def with_a_fake_rabbit_connnection(&block)
    manager = Headbutt::BunnyManager.instance
    connection = BunnyMock.new.tap(&:start)
    Headbutt::BunnyManager.instance = Headbutt::BunnyManager.new(connection)

    block.call(connection)

  ensure
    Headbutt::BunnyManager.instance = manager
  end
end

RSpec.configure do |config|
  config.include FakeRabbitConnection
end

module BunnyMock
  class Channel
    def ack(*args)
      puts 'here it is'
    end
  end
end
