#!/usr/bin/ruby -w

require 'cgi'

cgi = CGI.new('html4')
header = cgi.h3 { 'Enter the string you wish to encrypt:' }
encrypt_url = 'encrypt.rb'
toggle_verify_url = cgi.br + cgi.a('eyaml.rb?verify=true') { 'Show verification' }

# If you suspect that this tool may be mishandling a given secret, use verification mode
# It will repeat your input (in plaintext), the encrypted output, and decrypt that output again for visual confirmation (in plaintext)
if cgi['verify'] == 'true'
  header = cgi.h2('style' => 'color:red;') { 'Using verification: Input will be shown in plain text with results' } + header
  encrypt_url += '?verify=true'
  toggle_verify_url = cgi.br + cgi.a('eyaml.rb') { 'Hide verification' }
end

# Add encryption function form
html_out = cgi.form('POST', encrypt_url) do
  header + cgi.password_field('encrypt_request_str') + cgi.br +
  cgi.hidden('verify', cgi['verify'] == 'true' ? 'true' : 'false') + cgi.submit
end
# Add link to switch validation status
html_out += toggle_verify_url

# Add comparison function form
html_out += cgi.form('POST', 'compare.rb') do
  cgi.br + cgi.h3 { 'Enter the two encrypted strings you want to compare' } + cgi.text_field('compare_request_strA') + cgi.br + cgi.text_field('compare_request_strB') + cgi.br + cgi.submit
end

# Add HTML wrapper
html_out = cgi.html do
  cgi.head { cgi.title { 'Hiera-eyaml encrypt interface' } } +
  cgi.body do
    html_out
  end
end

# Write out HTML output through a beautifier
cgi.out { CGI.pretty(html_out) }
