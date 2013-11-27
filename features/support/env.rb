ENV['RUBYLIB'] = File.dirname(__FILE__) + '/../../lib'
require 'rubygems'
require 'aruba/config'
require 'aruba/cucumber'
require 'fileutils'
require 'rspec/expectations'
require 'hiera/backend/eyaml/parser/parser.rb'
require 'hiera/backend/eyaml/options'
require 'hiera/backend/eyaml/parser/encrypted_tokens'

test_files = {}
Dir["features/sandbox/**/*"].each do |file_name|
  next unless File.file? file_name
  read_mode = "r"
  read_mode = "rb" if file_name =~ /\.bin$/
  file = File.open(file_name, "r")
  file_contents = file.read
  file.close
  file_name = file_name.slice(17, file_name.length)
  test_files[file_name] = file_contents
end

# ENV['EDITOR']="/bin/cat"

Aruba.configure do |config|
  config.before_cmd do |cmd|
    SetupSandbox.create_files test_files
  end
end

Before do
  @aruba_timeout_seconds = 30
end
