# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hiera/backend/eyaml'

Gem::Specification.new do |gem|
  gem.name          = "hiera-eyaml"
  gem.version       = Hiera::Backend::Eyaml::VERSION
  gem.description   = "Hiera backend for decrypting encrypted yaml properties"
  gem.summary       = "OpenSSL Encryption backend for Hiera"
  gem.author        = "Tom Poulton"
  gem.license       = "MIT"

  gem.homepage      = "http://github.com/TomPoulton/hiera-eyaml"
  gem.files         = `git ls-files`.split($/).reject { |file| file =~ /^features.*$/ }
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency('trollop', '~> 2.0')
  gem.add_dependency('highline', '~> 1.6.19')
end
