Given(/^I set FACTER_(.*?) to "(.*?)"$/) do |facter, value|
  set_environment_variable "FACTER_#{facter}", value
end
