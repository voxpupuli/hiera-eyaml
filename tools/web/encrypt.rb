#!/usr/bin/ruby -w

require 'cgi'
require 'shellwords'

# Likely customizations for your environment
eyaml_path = '/usr/local/bin/eyaml'
private_key = '/etc/puppetlabs/puppet/eyaml.keys/private/puppet.eyaml.private_key.pkcs7.pem'
public_key = '/etc/puppetlabs/puppet/eyaml.keys/puppet.eyaml.public_key.pkcs7.pem'

cgi = CGI.new('html4')
footer = cgi.br + cgi.a(cgi.referer) { 'Back' }

# Perform some sanity checking on the input
if !cgi.key?('encrypt_request_str') || cgi['encrypt_request_str'] == ''''
  output_html = cgi.h2 { 'No input provided, try again.' }
else
  # Assume the user is using special characters that wouldn't play nice with a shell instance, so escape certain characters
  input = Shellwords.escape(cgi['encrypt_request_str'])

  # Perform the encryption
  encrypt_output = `#{eyaml_path} encrypt -o string --pkcs7-private-key=#{private_key} --pkcs7-public-key=#{public_key} -s #{input}`.strip!

  # Built output
  output_html = cgi.h3 { 'Encrypted Output:' } + cgi.blockquote('style' => 'word-wrap: break-word') { encrypt_output }
  if cgi['verify'] == 'true'
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
