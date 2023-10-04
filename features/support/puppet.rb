Given(/^I set FACTER_(.*?) to "(.*?)"$/) do |facter, value|
  ENV["FACTER_#{facter}"] = value
end
