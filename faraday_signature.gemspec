# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'signatures/faraday/version'

Gem::Specification.new do |spec|
  spec.name          = 'faraday_signature'
  spec.version       = Signatures::Faraday::VERSION
  spec.authors       = ['Jesus Prieto Colomina']
  spec.email         = ['chus1818@gmail.com']
  spec.summary       = %q(Signed requests for Faraday)
  spec.description   = %q(
    Handles singed requests in Faraday using a set of middlewares
  )
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'naught'
  spec.add_dependency 'signatures'
  spec.add_development_dependency 'faraday', '~> 0.9'
  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'pry'
end
