Given(/^my EDITOR is set to "(.*?)"$/) do |editor_command|
  set_environment_variable 'EDITOR', editor_command
end

Given(/^my HOME is set to "(.*?)"$/) do |home_dir|
  # HOME must be absolute
  set_environment_variable 'HOME', expand_path(home_dir)
end

Given(/^my EYAML_CONFIG is set to "(.*?)"$/) do |config_file|
  set_environment_variable 'EYAML_CONFIG', config_file
end

Given(/^my PATH contains "(.*?)"$/) do |path_value|
  abspath = expand_path(path_value)
  return if ENV['PATH'].start_with? abspath
  paths = [path_value] + ENV['PATH'].split(File::PATH_SEPARATOR)
  ENV['PATH'] = paths.join(File::PATH_SEPARATOR)
  prepend_environment_variable 'PATH', abspath + File::PATH_SEPARATOR
end
