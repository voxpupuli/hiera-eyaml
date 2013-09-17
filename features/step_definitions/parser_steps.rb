Given /^I make a parser instance with no regexs$/ do
  @parser = Hiera::Backend::Eyaml::Parser::Parser.new([])
end

Given /^I make a parser instance with the ENC regexs$/ do
  enc_string = Hiera::Backend::Eyaml::Parser::EncStringTokenType.new()
  enc_block = Hiera::Backend::Eyaml::Parser::EncBlockTokenType.new()
  @parser = Hiera::Backend::Eyaml::Parser::Parser.new([enc_string, enc_block])
end

Given /^I make a parser instance with the DEC regexs$/ do
  dec_string = Hiera::Backend::Eyaml::Parser::DecStringTokenType.new()
  dec_block = Hiera::Backend::Eyaml::Parser::DecBlockTokenType.new()
  @parser = Hiera::Backend::Eyaml::Parser::Parser.new([dec_string, dec_block])
end

And /^I load a file called (.*)$/ do |file|
  @content = File.read("features/sandbox/#{file}")
end

And /^I configure the keypair$/ do
  Hiera::Backend::Eyaml::Options[:pkcs7_public_key] = "features/sandbox/keys/public_key.pkcs7.pem"
  Hiera::Backend::Eyaml::Options[:pkcs7_private_key] = "features/sandbox/keys/private_key.pkcs7.pem"
end

When /^I parse the content$/ do
  @tokens = @parser.parse @content
end

Then /^I should have (\d+) tokens?$/ do |number_of_tokens|
  @tokens.size.should == number_of_tokens.to_i
end

Then /^token (\d+) should be a (.*)$/ do |index, class_name|
  actual_class_name = @tokens[index.to_i - 1].class.name
  actual_class_name.split('::').last.should == class_name
end

Then /^token (\d+) should start with "(.*)"$/ do |index, content|
  token = @tokens[index.to_i - 1]
  token.match.should =~ /^#{Regexp.escape(content)}/
end

Then /^token (\d+) should decrypt to start with "(.*)"$/ do |index, plain|
  token = @tokens[index.to_i - 1]
  token.plain_text.should =~ /^#{Regexp.escape(plain)}/
end
