# This is a test helper to designed to allow testing of code
# that calls exit and terminates the current thread, or changes
# the global setup in such a way it is difficult to revert (i.e.
# `trap`)
#
# By forking before this code is run the side affects are
# isolated for the testing code. As we still want to know
# if the test passed/failed and want clean error messaging
# we need to use pipes so that we can forward the results
# from the forked process back across to the testing process.
module RunInIsolation
  DEFAULT_TIMEOUT = 5

  def run_in_isolation(timeout: DEFAULT_TIMEOUT, &block)
    read, write = IO.pipe

    @fork_pid = fork do
      # use a custom failure notifier to forward errors back to the
      # testing process. This could also be done with rescue but as
      # rspec provides a clean way of doing this we should definitely
      # use it.
      RSpec::Support.failure_notifier = proc do |failure, _opts|
        write_result_to_buffer(write, timeout) { failure }
      end
      read.close
      write_result_to_buffer(write, timeout, &block)
    end

    write.close
    result_str = wait_for_buffer(read, @fork_pid, timeout)

    result = result_str == '' ? nil : Marshal.load(result_str)
    return result if result.is_a?(SystemExit) # without this it kills the parent process. :(
    raise(result) if result.is_a?(Exception)
    result
  end

  def forked_process_ended?
    Process.getpgid(@fork_pid)
    false
  rescue Errno::ESRCH
    true
  end

  def write_result_to_buffer(buffer, timeout)
    result = begin
        Timeout.timeout(timeout) do # timeout in the forked process as this will make testing cleaner
          yield
        end
      rescue Exception => e
        e
      end
    Marshal.dump(result, buffer)
    exit!(0) # skips exit handlers.
  end

  def wait_for_buffer(buffer, pid, timeout)
    result = nil
    begin
      Timeout.timeout(timeout + 1) do # larger timeout in the local processor just in case the child dies/zombies
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
