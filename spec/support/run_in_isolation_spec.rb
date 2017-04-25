require 'spec_helper'

RSpec.describe RunInIsolation do
  let(:runner) { double(:runner, start: true, stop: true) }

  class IsolationTest
    attr_reader :count

    def initialize(count)
      @count = count
    end
  end
  class IsolationErrorTest < StandardError; end
  class IsolationExceptionTest < Exception; end

  it 'wont wait indefinitely' do
    expect do
      run_in_isolation(timeout: 0.1) do
        sleep 1
        'after sleep'
      end
    end.to raise_error(Timeout::Error)
  end

  it 'will return the a result value' do
    result = run_in_isolation(timeout: 0.1) do
      'apples'
    end
    expect(result).to eq('apples')
    expect(result).not_to equal('apples') # different string instance
  end

  it 'will return the a result class' do
    result = run_in_isolation(timeout: 0.1) do
      IsolationTest.new(6)
    end
    expect(result).to be_a(IsolationTest)
    expect(result.count).to eq(6)
  end

  it 'will return the result class after a process delay which is less than the timeout' do
    result = run_in_isolation(timeout: 0.2) do
      sleep 0.1
      'after timeout'
    end
    expect(result).to eq('after timeout')
  end

  it 'will reraise any errors from the fork' do
    expect do
      run_in_isolation(timeout: 0.2) do
        raise IsolationErrorTest
      end
    end.to raise_error(IsolationErrorTest)
  end

  it 'will reraise Exceptions from the fork' do
    expect do
      run_in_isolation(timeout: 0.2) do
        raise IsolationExceptionTest
      end
    end.to raise_error(IsolationExceptionTest)
  end

  it 'raised errors will include the correct backtrace' do
    error = nil
    previous_line_num = nil
    begin
      previous_line_num = __LINE__
      run_in_isolation(timeout: 0.2) do
        raise IsolationErrorTest
      end
    rescue => e
      error = e
    end
    expect(error.backtrace[0]).to include("#{__FILE__}:#{previous_line_num + 2}")
  end

  it 'will correctly bubble rspec failures out of the forked process' do
    expect do
      run_in_isolation(timeout: 0.2) do
        expect(false).to be_truthy
      end
    end.to raise_exception(RSpec::Expectations::ExpectationNotMetError)
  end
end
