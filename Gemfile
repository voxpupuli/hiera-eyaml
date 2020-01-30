source 'https://rubygems.org/'

gemspec

def default_puppet_restriction
  # Puppet 6 should be the default for Ruby 2.5+
  # Puppet 5 should be the defualt for Ruby 2.4
  Gem::Requirement.create('>= 2.5.0').satisfied_by?(Gem::Version.new(RUBY_VERSION.dup)) ? '~> 6.0' : '~> 5.0'
end

def activesupport_restriction
  # Active Support 6.x requires ruby 2.5.0+
  Gem::Requirement.create('>= 2.5.0').satisfied_by?(Gem::Version.new(RUBY_VERSION.dup)) ? '~> 6.0' : '~> 5.0'
end

group :development do
  gem "aruba", '~> 0.6.2'
  gem "cucumber", '~> 1.1'
  gem "rspec-expectations", '~> 3.1.0'
  gem "hiera-eyaml-plaintext"
  gem "puppet", ENV['PUPPET_VERSION'] || default_puppet_restriction
  gem 'json_pure', '<= 2.0.1' if RUBY_VERSION < '2.0.0'
  if RUBY_VERSION >= '2.2.2'
    gem 'github_changelog_generator',  :require => false, :git => 'https://github.com/voxpupuli/github-changelog-generator', :branch => 'voxpupuli_essential_fixes'
    gem "activesupport", activesupport_restriction
  end
end

group :test do
  gem "rake"
end
