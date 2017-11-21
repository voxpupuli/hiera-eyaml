#!/usr/bin/ruby -w

require 'cgi'
require 'shellwords'

# Likely customizations for your environment
eyaml_path = '/usr/local/bin/eyaml'
private_key = '/etc/puppetlabs/puppet/eyaml.keys/private/puppet.eyaml.private_key.pkcs7.pem'
public_key = '/etc/puppetlabs/puppet/eyaml.keys/puppet.eyaml.public_key.pkcs7.pem'

cgi = CGI.new('html4')
footer = cgi.a(cgi.referer) { 'Back' }
output_html = ''

# Perform some sanity checking
# Be sure we got something to work with
if !cgi.key?('compare_request_strA') || cgi['compare_request_strA'] == '''' || !cgi.key?('compare_request_strB') || cgi['compare_request_strB'] == ''''
  output_html += cgi.h3 { 'Input missing, please try again.' }
# Be sure it looks like it's an eyaml string
elsif !(cgi['compare_request_strA'] =~ /ENC\[.*\]/) || !(cgi['compare_request_strB'] =~ /ENC\[.*\]/)
  output_html += cgi.h3 { "Input doesn't look like an eyaml encoded string, please try again." }
# Be sure it's not the exact same input since that's probably a copy/paste error
elsif cgi['compare_request_strA'] == cgi['compare_request_strB']
  output_html += cgi.h3 { "Both inputs are the same.  You probably didn't mean that, please try again." }
else
  # Assume all user input is malicious, run it through a shell escape sequence to sanitize input
  input_a = Shellwords.escape(cgi['compare_request_strA'])
  input_b = Shellwords.escape(cgi['compare_request_strB'])

  # Perform both decryptions
  decrypt_a_output = `#{eyaml_path} decrypt --pkcs7-private-key=#{private_key} --pkcs7-public-key=#{public_key} -s #{input_a}`
  decrypt_b_output = `#{eyaml_path} decrypt --pkcs7-private-key=#{private_key} --pkcs7-public-key=#{public_key} -s #{input_b}`

  output_html += cgi.h3 { 'Encrypted inputs do not match' }
  if decrypt_a_output == decrypt_b_output
    output_html = cgi.h3 { 'Encrypted inputs do match' }
  end
end
# Append footer
output_html += footer

# Append HTML wrapper
output_html = cgi.html do
  cgi.head { "\n" + cgi.title { 'Hiera-eyaml Comparison Result' } } +
  cgi.body do
    "\n" + output_html
  end
end

# Write out HTML response through a beautifier
cgi.out { CGI.pretty(output_html) }
