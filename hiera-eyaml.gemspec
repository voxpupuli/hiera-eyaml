# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hiera/backend/version'

Gem::Specification.new do |gem|
  gem.name          = "hiera-eyaml"
  gem.version       = Hiera::Backend::Eyaml::VERSION
  gem.description   = "Hiera backend for decrypting encrypted yaml properties"
  gem.summary       = "OpenSSL Encryption backend for Hiera"
  gem.email         = "paultont@example.com"
  gem.author        = "Tom Paulton"

  gem.homepage      = "http://github.com/TomPaulton/hiera-eyaml"
  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency('trollop', '>2.0')
end