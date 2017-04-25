module Headbutt
  module Middleware
    module Server
      class ActiveRecord
        def call(*)
          yield
        ensure
          ::ActiveRecord::Base.clear_active_connections!
        end
      end
    end
  end
end
