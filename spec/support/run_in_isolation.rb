module RunInIsolation
  DEFAULT_TIMEOUT = 5

  def run_in_isolation(timeout: DEFAULT_TIMEOUT, &block)
    read, write = IO.pipe

    @fork_pid = fork do
      RSpec::Support.failure_notifier = Proc.new  do |failure, _opts|
        write_result_to_buffer(write, timeout) { failure }
      end
      read.close
      write_result_to_buffer(write, timeout, &block)
    end

    write.close
    result_str = wait_for_buffer(read, @fork_pid, timeout)

    result = result_str == '' ? nil : Marshal.load(result_str)
    raise(result) if result.is_a?(Exception)
    result
  end

  def forked_process_ended?
    Process.getpgid(@fork_pid)
    false
  rescue Errno::ESRCH
    true
  end

  def write_result_to_buffer(buffer, timeout, &block)
    result =  begin
        Timeout.timeout(timeout) do # timeout in the forked code as this will make testing easier
          block.call
        end
      rescue => e
        e
      end
    Marshal.dump(result, buffer)
    exit!(0) # skips exit handlers.
  end

  def wait_for_buffer(buffer, pid, timeout)
    result = nil
    begin
      Timeout.timeout(timeout + 1) do # timeout in the local code just in case the child dies/zombies
        result = buffer.read
        Process.wait(pid)
      end
    rescue Timeout::Error
      Process.kill('TERM', pid)
      raise
    end
    result
  end
end

RSpec.configure do |config|
  config.include RunInIsolation
end
