$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "headbutt"
require "pry"

Dir['./spec/support/**/*.rb'].each do |f|
  require f
end
