ENV['RUBYLIB'] = File.dirname(__FILE__) + '/../../lib'
require 'rubygems'
require 'aruba/config'
require 'aruba/cucumber'
require 'fileutils'
require 'rspec/expectations'

Aruba.configure do |config|
  config.before_cmd do |cmd|
    Setup.create_inputs
  end
end
