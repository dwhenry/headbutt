require 'concurrent/map'
require 'concurrent/atomic/atomic_fixnum'

module Headbutt
  class Stats
    WORKER_STATE = Concurrent::Map.new
    PROCESSED = Concurrent::AtomicFixnum.new
    FAILURE = Concurrent::AtomicFixnum.new

    def self.thread_identity
      @str ||= Thread.current.object_id.to_s(36)
    end

    def self.record(worker, job_hash)
      tid = thread_identity
      WORKER_STATE[tid] = { :payload => job_hash, :run_at => Time.now.to_i }

      begin
        yield
      rescue Exception
        FAILURE.increment
        raise
      ensure
        WORKER_STATE.delete(tid)
        PROCESSED.increment
      end
    end
  end

  def self.Stats(worker, job_hash, &block)
    Stats.record(worker, job_hash, &block)
  end
end
