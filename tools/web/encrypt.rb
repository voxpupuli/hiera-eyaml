#!/usr/bin/ruby -w

require 'cgi'
require 'shellwords'
require 'tempfile'
require 'stringio'

# Likely customizations for your environment
eyaml_path = '/usr/local/bin/eyaml'
private_key = '/etc/puppetlabs/puppet/eyaml.keys/private/puppet.eyaml.private_key.pkcs7.pem'
public_key = '/etc/puppetlabs/puppet/eyaml.keys/puppet.eyaml.public_key.pkcs7.pem'

cgi = CGI.new('html4')
footer = cgi.br + cgi.a(cgi.referer) { 'Back' }

# Perform some sanity checking on the input
if (!cgi.key?('encrypt_request_str') || cgi['encrypt_request_str'].string == '''') && (!cgi.key?('encrypt_request_file') || cgi['encrypt_request_file'].original_filename == '''')
  output_html = cgi.h2 { 'No input provided, try again.' }
else
  input = ""
  output_html = ""
  # Assume the user is using special characters that wouldn't play nice with a shell instance, so escape certain characters
  if cgi['encrypt_request_str'].string != ''''
    input = cgi['encrypt_request_str'].string
  else
    input = cgi['encrypt_request_file'].read
  end

  # Write out input to a temp file to fix escaping and length issues with SSL certificates for example
  tmpfile = Tempfile.new('hiera-eyaml-web')
  tmpfile << input
  tmpfile.flush

  # Perform the encryption
  encrypt_command = "#{eyaml_path} encrypt -o string --pkcs7-private-key=#{private_key} --pkcs7-public-key=#{public_key} -f #{tmpfile.path}"
  encrypt_output = `#{encrypt_command}`.strip!

  # Built output
  output_html += cgi.h3 { 'Encrypted Output:' } + cgi.blockquote('style' => 'word-wrap: break-word') { encrypt_output }
  if cgi['verify'].string == 'true'
    decrypt_output = `#{eyaml_path} decrypt --pkcs7-private-key=#{private_key} --pkcs7-public-key=#{public_key} -s #{encrypt_output}`.strip!
    output_html = cgi.h3 { 'Original Input:' } + cgi.blockquote { input } + output_html
    output_html += cgi.h3 { 'Decrypted Output Verification:' } + cgi.blockquote { decrypt_output }
  end
end

output_html += footer

# Add HTML outer wrapper
output_html = cgi.html do
  cgi.head { cgi.title { 'Hiera-eyaml Encrypt Result' } } +
  cgi.body do
    output_html
  end
end

# Write out response through an HTML beautifier
cgi.out do
  CGI.pretty(output_html)
end