$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'headbutt'
require 'pry'

Dir['./spec/support/**/*.rb'].each do |f|
  require f unless f =~ /_spec\.rb/
end

RSpec.configure do |c|
  c.before do
    # stop logging from being written to STDOUT during testing
    Headbutt.logger.level = 6
  end
end
