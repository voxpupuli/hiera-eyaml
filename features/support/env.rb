rubylib = (ENV['RUBYLIB'] || '').split(File::PATH_SEPARATOR)
rubylib.unshift %(#{File.dirname(__FILE__) + '/../../lib'})
ENV['RUBYLIB'] = rubylib.uniq.join(File::PATH_SEPARATOR)
require 'rubygems'
require 'aruba'
require 'aruba/cucumber'
require 'fileutils'
require 'pathname'
require 'rspec/expectations'
require 'hiera/backend/eyaml/parser/parser'
require 'hiera/backend/eyaml/options'
require 'hiera/backend/eyaml/parser/encrypted_tokens'

test_files = {}
Dir.glob('features/sandbox/**/*', File::FNM_DOTMATCH).each do |file_name|
  next unless File.file? file_name

  read_mode = 'r'
  read_mode = 'rb' if /\.bin$/.match?(file_name)
  file = File.open(file_name, 'r')
  file_contents = file.read
  file.close
  file_name = file_name.slice(17, file_name.length)
  test_files[file_name] = file_contents
end

Aruba.configure do |config|
  # A number of checks require absolute paths.
  config.allow_absolute_paths = true
  # Setup the test environment.
  config.before :command do |cmd|
    SetupSandbox.create_files aruba.config.working_directory, test_files
  end
end

Before do
  home_dir = 'clean_home'
  # set to a non-existant home in order so rogue configs don't confuse
  #set_environment_variable 'HOME', home_dir
  ## But it must be an absolute path for other code
  # e.g. puppet will throw: "Error: Could not initialize global default settings: non-absolute home"
  set_environment_variable 'HOME', expand_path(home_dir)
  set_environment_variable 'EYAML_CONFIG', ''
  @aruba_timeout_seconds = 30
end
