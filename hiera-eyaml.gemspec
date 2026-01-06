lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hiera/backend/eyaml'

Gem::Specification.new do |gem|
  gem.name          = 'hiera-eyaml'
  gem.version       = Hiera::Backend::Eyaml::VERSION
  gem.description   = 'Hiera backend for decrypting encrypted yaml properties'
  gem.summary       = 'OpenSSL Encryption backend for Hiera'
  gem.author        = 'Vox Pupuli'
  gem.email         = 'voxpupuli@groups.io'
  gem.license       = 'MIT'

  gem.homepage      = 'https://github.com/voxpupuli/hiera-eyaml/'
  gem.files         = `git ls-files`.split($/).reject { |file| file =~ /^features.*$/ }
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.require_paths = ['lib']

  gem.add_dependency 'base64', '~> 0.3.0'
  gem.add_dependency 'highline', '>= 2.1', '< 4'
  gem.add_dependency 'optimist', '~> 3.1'

  gem.add_development_dependency 'rake', '~> 13.2', '>= 13.2.1'
  gem.add_development_dependency 'rspec-expectations', '~> 3.13'
  gem.add_development_dependency 'voxpupuli-rubocop', '~> 3.1.0'

  gem.required_ruby_version = '>= 2.7', ' < 5'
end
