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

  gem.add_runtime_dependency 'highline', '~> 2.1'
  gem.add_runtime_dependency 'optimist', '~> 3.0', '>= 3.0.1'

  gem.add_development_dependency 'rake', '~> 13.0', '>= 13.0.6'
  # 1.51 requires Ruby 2.7
  gem.add_development_dependency 'rubocop', '~> 1.50.0'
  # 1.18 requires Ruby 2.7
  gem.add_development_dependency 'rspec-expectations', '~> 3.12.3'
  gem.add_development_dependency 'rubocop-performance', '~> 1.17', '>= 1.17.1'
  gem.add_development_dependency 'rubocop-rake', '~> 0.6.0'
  # 2.21 requires Ruby 2.7
  gem.add_development_dependency 'rubocop-rspec', '~> 2.20.0'

  gem.required_ruby_version = '>= 2.7', ' < 4'
end
