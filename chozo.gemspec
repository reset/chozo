# -*- encoding: utf-8 -*-
require File.expand_path('../lib/chozo/version', __FILE__)

Gem::Specification.new do |s|
  s.authors       = ["Jamie Winsor"]
  s.email         = ["jamie@vialstudios.com"]
  s.description   = %q{TODO: A collection of supporting libraries and Ruby core extensions}
  s.summary       = s.description
  s.homepage      = "https://github.com/reset/chozo"

  s.files         = `git ls-files`.split($\)
  s.executables   = s.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(spec)/})
  s.name          = "chozo"
  s.require_paths = ["lib"]
  s.version       = Chozo::VERSION
  s.required_ruby_version = ">= 1.9.1"

  s.add_runtime_dependency 'activemodel'
  s.add_runtime_dependency 'multi_json', '>= 1.3.0'

  s.add_development_dependency 'thor'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'fuubar'
  s.add_development_dependency 'spork'
  s.add_development_dependency 'yard'
  s.add_development_dependency 'guard'
  s.add_development_dependency 'guard-rspec'
  s.add_development_dependency 'guard-spork'
  s.add_development_dependency 'guard-yard'
  s.add_development_dependency 'coolline'
  s.add_development_dependency 'redcarpet'
  s.add_development_dependency 'json_spec'
end
