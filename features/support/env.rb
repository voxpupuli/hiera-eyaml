rubylib = (ENV["RUBYLIB"] || "").split(File::PATH_SEPARATOR)
rubylib.unshift %|#{File.dirname(__FILE__) + '/../../lib'}|
ENV["RUBYLIB"] = rubylib.uniq.join(File::PATH_SEPARATOR)
require 'rubygems'
require 'aruba/config'
require 'aruba/cucumber'
require 'fileutils'
require 'pathname'
require 'rspec/expectations'
require 'hiera/backend/eyaml/parser/parser.rb'
require 'hiera/backend/eyaml/options'
require 'hiera/backend/eyaml/parser/encrypted_tokens'

test_files = {}
Dir.glob("features/sandbox/**/*", File::FNM_DOTMATCH).each do |file_name|
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
    # when executing, resolve the SANDBOX_HOME into a real HOME
    ENV['HOME'] = Pathname.new(ENV['SANDBOX_HOME']).realpath.to_s
  end
end

Before do
  # set to a non-existant home in order so rogue configs don't confuse
  ENV['SANDBOX_HOME'] = 'clean_home'
  ENV['EYAML_CONFIG'] = nil
  @aruba_timeout_seconds = 30
end
