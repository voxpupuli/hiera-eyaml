Then /the output should have a key of '(.*?)' with ([0-9]*?) lines/ do |key, lines|
  require 'yaml'
  #puts all_output
  data = YAML.load(all_output)
  expect(data[key]).not_to be_nil 
  expect(data[key].scan(/[\r\n]+/).size).to eq(lines.to_i)
end
