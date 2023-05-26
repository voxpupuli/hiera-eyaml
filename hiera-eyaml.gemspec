# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hiera/backend/eyaml'

Gem::Specification.new do |gem|
  gem.name          = "hiera-eyaml"
  gem.version       = Hiera::Backend::Eyaml::VERSION
  gem.description   = "Hiera backend for decrypting encrypted yaml properties"
  gem.summary       = "OpenSSL Encryption backend for Hiera"
  gem.author        = "Vox Pupuli"
  gem.email         = "voxpupuli@groups.io"
  gem.license       = "MIT"

  gem.homepage      = "https://github.com/voxpupuli/hiera-eyaml/"
  gem.files         = `git ls-files`.split($/).reject { |file| file =~ /^features.*$/ }
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency('optimist')
  gem.add_dependency('highline')

  gem.required_ruby_version = '>= 2.6', ' < 4'
end
