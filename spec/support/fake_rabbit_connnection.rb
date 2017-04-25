require 'bunny-mock'

module FakeRabbitConnection
  def with_a_fake_rabbit_connnection
    manager = Headbutt::BunnyManager.instance
    connection = BunnyMock.new.tap(&:start)
    Headbutt::BunnyManager.instance = Headbutt::BunnyManager.new(connection)

    yield(connection)

  ensure
    Headbutt::BunnyManager.instance = manager
  end
end

RSpec.configure do |config|
  config.include FakeRabbitConnection
end

# Remove once https://github.com/arempe93/bunny-mock/pull/30 has been merged
module BunnyMock
  class Channel
    def ack(*args)
    end

    def nack(*args)
    end
  end
end
