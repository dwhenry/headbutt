require 'spec_helper'

RSpec.describe Headbutt::Trapper do
  let(:runner_class) do
    Class.new do
      def initialize(signal = nil)
        @signal = signal
      end

      def start
        Process.kill(@signal, Process.pid)
      end

      def stop
      end
    end
  end

  it 'When TERM signal is sent' do
    runner = runner_class.new('TERM')
    run_in_isolation(timeout: 1) do
      expect(runner).to receive(:start).and_call_original # need to send kill signal from within loop
      expect(runner).to receive(:stop)
      expect(Headbutt.logger).to receive(:info).with('Shutting down')
      expect(Headbutt.logger).to receive(:info).with('Bye!')
      trapper = Headbutt::Trapper.new(runner)
      trapper.start
      runner.log
    end

    expect(forked_process_ended?).to be_truthy
  end
end
