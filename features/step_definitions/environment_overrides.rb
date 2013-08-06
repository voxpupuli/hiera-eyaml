Given /^my EDITOR is set to \"(.*?)\"$/ do |editor_command|
  ENV['EDITOR'] = editor_command
end