# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'headbutt/version'

Gem::Specification.new do |spec|
  spec.name          = 'headbutt'
  spec.version       = Headbutt::VERSION
  spec.authors       = ['David Henry']
  spec.email         = ['david@decoybecoy.com']

  spec.summary       = 'Drop in replacement for sidekiq'
  spec.description   = 'sometims you need to hurt yourself in order to hurt others.'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^spec/})
  end
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'concurrent-ruby', '~> 1.0'
  spec.add_development_dependency 'bundler', '~> 1.13'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'bunny-mock'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'rubocop'
end
