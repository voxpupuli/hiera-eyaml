source 'https://rubygems.org/'

gemspec

group :development do
  gem "aruba", '~> 0.6.2'
  gem "cucumber", '~> 1.1'
  gem "rspec-expectations", '~> 3.1.0'
  gem "hiera-eyaml-plaintext"
  gem "puppet", ENV['PUPPET_VERSION'] || '~> 5.0'
  gem 'json_pure', '<= 2.0.1' if RUBY_VERSION < '2.0.0'
end

group :test do
  gem "rake"
end
