require 'spec_helper'

RSpec.describe Headbutt::Middleware::Chain do
  describe 'middleware chain' do
    let(:recorder) { [] }

    class CustomMiddleware
      def initialize(name, recorder)
        @name = name
        @recorder = recorder
      end

      def call(*)
        @recorder << [@name, 'before']
        yield
        @recorder << [@name, 'after']
      end
    end

    class AnotherCustomMiddleware < CustomMiddleware; end
    class YetAnotherCustomMiddleware < CustomMiddleware; end

    class CustomWorker
      include Headbutt::Worker

      def perform(recorder)
        recorder << ['work_performed']
      end
    end

    class NonYieldingMiddleware
      def call(*)
      end
    end

    it 'supports custom middleware' do
      chain = described_class.new
      chain.add CustomMiddleware, 1, []

      expect(chain.entries.last.klass).to eq(CustomMiddleware)
    end

    it 'executes middleware in the proper order' do
      Headbutt.server_middleware do |chain|
        # should only add once, second should replace the first
        2.times { |i| chain.add CustomMiddleware, i.to_s, recorder }
        chain.insert_before CustomMiddleware, AnotherCustomMiddleware, '2', recorder
        chain.insert_after AnotherCustomMiddleware, YetAnotherCustomMiddleware, '3', recorder
      end

      processor = Headbutt::Processor.new
      msg = {
        'class' => CustomWorker.to_s,
        'args' => [recorder],
        'jid' => SecureRandom.uuid
      }
      allow(Headbutt).to receive(:load_json).and_return(msg) # hack to skip JSON serialization/deserialization
      processor.process(Headbutt.dump_json(msg))
      expect(recorder.flatten).to eq(%w(2 before 3 before 1 before work_performed 1 after 3 after 2 after))
    end

    it 'correctly replaces middleware when using middleware with options in the initializer' do
      chain = described_class.new
      chain.add NonYieldingMiddleware
      chain.add NonYieldingMiddleware, {:foo => 5}
      expect(chain.count).to eq(1)
    end

    it 'correctly prepends middleware' do
      chain = described_class.new
      chain_entries = chain.entries
      chain.add CustomMiddleware
      chain.prepend YetAnotherCustomMiddleware
      expect(chain_entries.map(&:klass)).to eq([YetAnotherCustomMiddleware, CustomMiddleware])
    end

    it 'allows middleware to abruptly stop processing rest of chain' do
      recorder = []
      chain = described_class.new
      chain.add NonYieldingMiddleware
      chain.add CustomMiddleware, 1, recorder

      final_action = nil
      chain.invoke { final_action = true }
      expect(final_action).to be_nil
      expect(recorder).to be_empty
    end
  end

  # describe 'i18n' do
  #   before do
  #     require 'i18n'
  #     I18n.enforce_available_locales = false
  #     require 'hedabutt/middleware/i18n'
  #   end
  #
  #   it 'saves and restores locale' do
  #     I18n.locale = 'fr'
  #     msg = {}
  #     mw = Headbutt::Middleware::I18n::Client.new
  #     mw.call(nil, msg, nil, nil) { }
  #     assert_equal :fr, msg['locale']
  #
  #     msg['locale'] = 'jp'
  #     I18n.locale = I18n.default_locale
  #     assert_equal :en, I18n.locale
  #     mw = Headbutt::Middleware::I18n::Server.new
  #     mw.call(nil, msg, nil) do
  #       assert_equal :jp, I18n.locale
  #     end
  #     assert_equal :en, I18n.locale
  #   end
  #
  #   it 'supports I18n.enforce_available_locales = true' do
  #     I18n.enforce_available_locales = true
  #     I18n.available_locales = [:en, :jp]
  #
  #     msg = { 'locale' => 'jp' }
  #     mw = Headbutt::Middleware::I18n::Server.new
  #     mw.call(nil, msg, nil) do
  #       assert_equal :jp, I18n.locale
  #     end
  #
  #     I18n.enforce_available_locales = false
  #     I18n.available_locales = nil
  #   end
  # end
end
