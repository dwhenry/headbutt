module RunInIsolation
  TIMEOUT = 5

  def run_in_isolation
    read, write = IO.pipe
    result = nil

    pid = fork do
      read.close
      write_result_to_buffer(write)
    end

    write.close
    result = wait_for_buffer(read, pid, TIMEOUT)

    raise 'child failed' if result.empty?
    result = Marshal.load(result)
    if result.is_a?(Exception)
      raise result
    else
      result
    end
  end

  def write_result_to_buffer(buffer)
    result =  begin
        yield
      rescue => e
        e
      end
    Marshal.dump(result, buffer)
    exit!(0) # skips exit handlers.
  end

  def wait_for_buffer(buffer, pid, timeout)
    result = nil
    begin
      Timeout.timeout(timeout) do
        result = read.read
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
