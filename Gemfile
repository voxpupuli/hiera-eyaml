source 'https://rubygems.org/'

gemspec

group :development do
  gem "aruba", '~> 0.6.2'
  gem "cucumber", '~> 1.1'
  gem "rspec-expectations", '~> 3.1.0'
  gem "hiera-eyaml-plaintext"
  gem "puppet", ENV['PUPPET_VERSION'] || '>= 7'
  gem 'github_changelog_generator', :require => false, :git => 'https://github.com/voxpupuli/github-changelog-generator', :branch => 'voxpupuli_essential_fixes'
  gem "activesupport"
end

group :test do
  gem "rake"
end
