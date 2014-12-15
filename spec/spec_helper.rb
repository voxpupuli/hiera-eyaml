require 'rspec'
require 'mocha'
require 'mocha/test_unit'

RSpec.configure do |config|
  config.mock_framework = :mocha
  config.color = true
end
