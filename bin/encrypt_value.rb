#!/usr/bin/env ruby
require 'openssl'
require 'base64'

# Run from this directory using: ruby encrypt_value.rb "value to encrypt"

public_key_path = 'keys/public_key.pem'

plain_text = ARGV[0]
public_key_arg = ARGV[1]

if public_key_arg
    public_key_path = public_key_arg
end
puts "using #{public_key_path} to encrypt value"

public_key = OpenSSL::PKey::RSA.new(File.read( public_key_path ))

cipher_binary = public_key.public_encrypt( plain_text )
cipher_text = Base64.encode64( cipher_binary )

puts cipher_text
