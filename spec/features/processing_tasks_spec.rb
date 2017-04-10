require 'spec_helper'

RSpec.describe Headbutt::Processor do
  before do
    allow(Headbutt).to receive(:logger).and_return(double(warn: true, info: true))
    subject.terminate # this stops us starting an infinite loop but requesting exit once the process has been run.
  end

  around do |example|
    with_a_fake_rabbit_connnection do
      example.run
    end
  end

  context 'under the default config(ish)' do
    it 'can successfully execute tasks' do
      args = []
      worker = build_test_worker { |name| args << name }

      message = {
        class: worker.to_s,
        jid: SecureRandom.uuid,
        args: ['Apples'],
      }

      Headbutt::BunnyManager.instance.task_queue.publish message.to_json
      subject.process_loop

      expect(args).to eq(['Apples'])
    end

    it 'will requeue failed tasks' do
      worker = build_test_worker { |_name| raise(StandardError) }

      message = {
        class: worker.to_s,
        jid: SecureRandom.uuid,
        args: ['Apples'],
      }

      Headbutt::BunnyManager.instance.task_queue.publish message.to_json
      expect { subject.process_loop }.to raise_error(StandardError)

      # would be nice if this would move the message back to the expected queue after the/a timeout
      expect(Headbutt::BunnyManager.instance.task_retry_queue.message_count).to eq(1)
    end
  end

  context 'with a custom config that removes the retry code' do
    before do
      empty_middleware = Headbutt::Middleware::Chain.new
      expect(Headbutt).to receive(:server_middleware).and_return(empty_middleware)
    end

    it 'wont requeue failed tasks' do
      worker = build_test_worker { |_name| raise(StandardError) }

      message = {
        class: worker.to_s,
        jid: SecureRandom.uuid,
        args: ['Apples'],
      }

      Headbutt::BunnyManager.instance.task_queue.publish message.to_json
      expect { subject.process_loop }.to raise_error(StandardError)

      # would be nice if this would move the message back to the expected queue after the/a timeout
      expect(Headbutt::BunnyManager.instance.task_retry_queue.message_count).to eq(0)
    end
  end
end
