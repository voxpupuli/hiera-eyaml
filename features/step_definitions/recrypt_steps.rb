Given(/I recrypt a file/) do
  @enc_parser = Hiera::Backend::Eyaml::Parser::ParserFactory.encrypted_parser
  @dec_parser = Hiera::Backend::Eyaml::Parser::ParserFactory.decrypted_parser
end

And(/^I recrypt it twice$/) do
  @tokens = @enc_parser.parse @content
  @decrypted_content = @tokens.each_with_index.to_a.map { |(t, index)| t.to_decrypted index: index }.join

  @edited_tokens = @dec_parser.parse @decrypted_content
  @encrypted_output = @edited_tokens.map { |t| t.to_encrypted }.join

  @tokens_check = @enc_parser.parse @encrypted_output
  @decrypted_content_check = @tokens.each_with_index.to_a.map { |(t, index)| t.to_decrypted index: index }.join
end

Then(/the recrypted tokens should match/) do
  @tokens.size.to_i.should == @tokens_check.size.to_i
end

Then(/the recrypted decrypted content should match/) do
  @decrypted_content == @decrypted_content_check
end

Then(/the recrypted contents should differ/) do
  @content != @encrypted_output
end

Then(/^the tokens at (\d+) should match/) do |index|
  decrypted1 = @tokens[index.to_i]
  decrypted2 = @tokens_check[index.to_i]
  decrypted1.to_decrypted.should == decrypted2.to_decrypted
end
