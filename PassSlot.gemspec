# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'PassSlot/version'

Gem::Specification.new do |spec|
  spec.name          = "PassSlot"
  spec.version       = PassSlot::VERSION
  spec.authors       = ["PassSlot"]
  spec.email         = ["dev@passslot.com"]
  spec.summary       = %q{PassSlot Ruby SDK}
  spec.description   = %q{PassSlot is a Passbook service that makes Passbook usage easy for everybody. It helps you design and distribute mobile passes to all major mobile platforms.}
  spec.homepage      = "http://www.passslot.com"
  spec.license       = "Apache License 2.0"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "faraday", "~> 0.9.0"
  spec.add_dependency "faraday_middleware", "~> 0.9.1"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
end
