Given(/^I make a parser instance with no regexs$/) do
  @parser = Hiera::Backend::Eyaml::Parser::Parser.new([])
end

Given(/^I make a parser instance with the ENC regexs$/) do
  @parser = Hiera::Backend::Eyaml::Parser::ParserFactory.encrypted_parser
end

Given(/^I make a parser instance with the DEC regexs$/) do
  @parser = Hiera::Backend::Eyaml::Parser::ParserFactory.decrypted_parser
end

And(/^I load a file called (.*)$/) do |file|
  @content = File.read("features/sandbox/#{file}")
end

And(/^I configure the keypair$/) do
  Hiera::Backend::Eyaml::Options[:pkcs7_public_key] = 'features/sandbox/keys/public_key.pkcs7.pem'
  Hiera::Backend::Eyaml::Options[:pkcs7_private_key] = 'features/sandbox/keys/private_key.pkcs7.pem'
  Hiera::Backend::Eyaml::Options[:pkcs7_public_key_env_var] = nil
  Hiera::Backend::Eyaml::Options[:pkcs7_private_key_env_var] = nil
  # This needs to carry over to the later steps, so must modify modify both the
  # fake ENV state and the real ENV state.
  delete_environment_variable 'EYAML_PUBLIC_KEY'
  delete_environment_variable 'EYAML_PRIVATE_KEY'
  ENV['EYAML_PUBLIC_KEY']=''
  ENV['EYAML_PRIVATE_KEY']=''
end

And(/^I configure the keypair using envvars$/) do
  Hiera::Backend::Eyaml::Options[:pkcs7_public_key] = nil
  Hiera::Backend::Eyaml::Options[:pkcs7_private_key] = nil
  Hiera::Backend::Eyaml::Options[:pkcs7_public_key_env_var] = 'EYAML_PUBLIC_KEY'
  Hiera::Backend::Eyaml::Options[:pkcs7_private_key_env_var] = 'EYAML_PRIVATE_KEY'
end

And(/^I load the keypair into envvars$/) do
  d = aruba.config.root_directory
  # Validate that the files exist
  pubkeyfile = File.join(d, 'features', 'sandbox', 'keys', 'public_key.pkcs7.pem')
  privkeyfile = File.join(d, 'features', 'sandbox', 'keys', 'private_key.pkcs7.pem')
  expect(File.exist?(pubkeyfile)).to be_truthy
  expect(File.exist?(privkeyfile)).to be_truthy

  # Load the files and validate
  pubkey = File.read(pubkeyfile)
  privkey = File.read(privkeyfile)
  expect(pubkey).not_to be_empty
  expect(privkey).not_to be_empty

  # Use keys
  # This needs to carry over to the later steps, so must modify modify both the
  # fake ENV state and the real ENV state.
  set_environment_variable 'EYAML_PUBLIC_KEY', pubkey
  set_environment_variable 'EYAML_PRIVATE_KEY', privkey
  ENV['EYAML_PUBLIC_KEY']=pubkey
  ENV['EYAML_PRIVATE_KEY']=privkey
end

When(/^I parse the content$/) do
  @tokens = @parser.parse @content
end

Then(/^I should have (\d+) tokens?$/) do |number_of_tokens|
  expect(@tokens.size).to eq (number_of_tokens.to_i)
end

Then(/^token (\d+) should be a (.*)$/) do |index, class_name|
  actual_class_name = @tokens[index.to_i - 1].class.name
  expect(actual_class_name.split('::').last).to eq class_name
end

Then(/^token (\d+) should start with "(.*)"$/) do |index, content|
  token = @tokens[index.to_i - 1]
  expect(token.match).to match(/^#{Regexp.escape(content)}/)
end

Then(/^token (\d+) should decrypt to start with "(.*)"$/) do |index, plain|
  token = @tokens[index.to_i - 1]
  expect(token.plain_text).to match(/^#{Regexp.escape(plain)}/)
end

Then(/^token (\d+) should decrypt to a string with UTF-8 encodings$/) do |index|
  token = @tokens[index.to_i - 1]
  expect(token.plain_text.encoding.to_s).to eq 'UTF-8'
end

And(/^map it to index decrypted values$/) do
  @decrypted = @tokens.each_with_index.to_a.map do |(t, index)|
    t.to_decrypted index: index
  end
end

Then(/^decryption (\d+) should be "(.*)"$/) do |index, content|
  decrypted = @decrypted[index.to_i]
  expect(decrypted).to eq content
end

Then(/^token (\d+) id should be (\d+)$/) do |index, token_id|
  token = @tokens[index.to_i - 1]
  expect(token.id).to eq (token_id.to_i)
end
