Given(/^my EDITOR is set to "(.*?)"$/) do |editor_command|
  ENV['EDITOR'] = editor_command
end

Given(/^my HOME is set to "(.*?)"$/) do |home_dir|
  ENV['SANDBOX_HOME'] = home_dir
end

Given(/^my EYAML_CONFIG is set to "(.*?)"$/) do |config_file|
  ENV['EYAML_CONFIG'] = config_file
end

Given(/^my PATH contains "(.*?)"$/) do |path_value|
  return if ENV['PATH'].start_with? path_value

  paths = [path_value] + ENV['PATH'].split(File::PATH_SEPARATOR)
  ENV['PATH'] = paths.join(File::PATH_SEPARATOR)
end
