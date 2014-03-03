Given /^my EDITOR is set to \"(.*?)\"$/ do |editor_command|
  ENV['EDITOR'] = editor_command
end

Given /^my HOME is set to \"(.*?)\"$/ do |home_dir|
  ENV['SANDBOX_HOME'] = home_dir
end

Given /^my EYAML_CONFIG is set to \"(.*?)\"$/ do |config_file|
  ENV['EYAML_CONFIG'] = config_file
end