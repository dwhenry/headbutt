require 'spec_helper'

RSpec.describe Headbutt::Processor do
  context 'under the default config(ish)' do
    it 'can successfully execute tasks' do
      with_a_fake_rabbit_connnection do |connection|
        message = {
          class: 'SuccessfulTestWorker',
          jid: SecureRandom.uuid,
          args: [],
        }

        expect(SuccessfulTestWorker).to receive(:perform)
        queue = connection.channel.queue Headbutt::BunnyManager::TASK_QUEUE
        queue.publish message.to_json

        subject.terminate
        subject.process_loop
      end
    end

    it 'will requeue failed tasks'
  end

  context 'with a custom config that removed the retry code' do
    it 'wont requeue failed tasks'
  end
end
