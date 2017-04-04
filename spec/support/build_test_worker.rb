module BuildTestWorker
  def build_test_worker(&block)
    name = 'TestWorker'
    name << Time.now.to_i.to_s
    name << '_'
    name << rand(999).to_s
    klass = Class.new do
      include Headbutt::Worker
      define_method :perform, &block
    end
    BuildTestWorker.const_set(name, klass)
  end
end

RSpec.configure do |config|
  config.include BuildTestWorker
end
