require 'spec_helper'

RSpec.describe Headbutt::Trapper do
  let(:runner) { double(:runner, start: true, stop: true) }

  it 'wont wait indefinitely' do
    run_in_isolation do
      trapper = Headbutt::Trapper.new(runner)
      trapper.start
    end
  end
end
