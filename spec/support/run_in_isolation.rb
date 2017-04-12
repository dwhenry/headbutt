module RunInIsolation
  DEFAULT_TIMEOUT = 5

  def run_in_isolation(timeout: DEFAULT_TIMEOUT, &block)
    read, write = IO.pipe

    pid = fork do
      read.close
      write_result_to_buffer(write, &block)
    end

    write.close
    result_str = wait_for_buffer(read, pid, timeout)

    raise 'child failed' if result_str.empty?
    result = Marshal.load(result_str)
    raise(result) if result.is_a?(Exception)
    result
  end

  def write_result_to_buffer(buffer, &block)
    result =  begin
      block.call
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
