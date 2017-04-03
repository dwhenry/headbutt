require 'spec_helper'

RSpec.describe Headbutt::Processor do
  context 'under the default config(ish)' do
    before do
      allow(Headbutt).to receive(:logger).and_return(double(warn: true, info: true))
    end

    it 'can successfully execute tasks' do
      args = []
      worker = build_worker do |name|
        args << name
      end

      with_a_fake_rabbit_connnection do
        message = {
          class: worker.to_s,
          jid: SecureRandom.uuid,
          args: ['Apples'],
        }

        Headbutt::BunnyManager.instance.task_queue.publish message.to_json

        subject.terminate # this stops us starting an infinite loop but requesting exit once the process has been run.
        subject.process_loop

        expect(args).to eq(['Apples'])
      end
    end

    it 'will requeue failed tasks' do
      worker = build_worker do |name|
        raise StandardError
      end

      with_a_fake_rabbit_connnection do
        message = {
          class: worker.to_s,
          jid: SecureRandom.uuid,
          args: ['Apples'],
        }

        Headbutt::BunnyManager.instance.task_queue.publish message.to_json

        subject.terminate # this stops us starting an infinite loop but requesting exit once the process has been run.
        expect { subject.process_loop }.to raise_error(StandardError)

        # would be nice if this would move the message back to the expected queue after the/a timeout
        expect(Headbutt::BunnyManager.instance.task_retry_queue.message_count).to eq(1)
      end

    end
  end

  context 'with a custom config that removes the retry code' do
    it 'wont requeue failed tasks' do

    end
  end

  def build_worker(&block)
    name = 'TestWorker'
    name << Time.now.to_i.to_s
    name << '_'
    name << rand(999).to_s
    klass = Class.new do
      include Headbutt::Worker
      define_method :perform, &block
    end
    self.class.const_set(name, klass)
  end
end
