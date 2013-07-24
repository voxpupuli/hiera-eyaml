require 'openssl'
require 'base64'
require 'hiera/backend/eyaml/encryptor'

module Hiera
  module Backend
    module Eyaml
      module Encryptors

        ENCRYPT_TAG = "PKCS7"

        class Pkcs7 < Encryptor

          def encrypt_string plaintext

            public_key_pem = File.read( "#{options[:public_key_dir]}/public_key.pkcs7.pem" )
            public_key = OpenSSL::X509::Certificate.new( public_key_pem )

            cipher = OpenSSL::Cipher::AES.new(256, :CBC)
            ciphertext_binary = OpenSSL::PKCS7::encrypt([public_key], plaintext, cipher, OpenSSL::PKCS7::BINARY).to_der
            ciphertext_as_block = Base64.encode64(ciphertext_binary).strip

            ciphertext_as_block
            
          end

          def decrypt_string ciphertext

            ciphertext_decoded = Base64.decode64(ciphertext)

            private_key_pem = File.read( "#{options[:private_key_dir]}/private_key.pkcs7.pem" )
            private_key = OpenSSL::PKey::RSA.new( private_key_pem )

            public_key_pem = File.read( "#{options[:public_key_dir]}/public_key.pkcs7.pem" )
            public_key = OpenSSL::X509::Certificate.new( public_key_pem )

            pkcs7 = OpenSSL::PKCS7.new( ciphertext_decoded )

            plaintext = pkcs7.decrypt(private_key, public_key)

            plaintext

          end

          def create_keys

            # Try to do equivalent of:
            # openssl req -x509 -nodes -days 100000 -newkey rsa:2048 -keyout privatekey.pem -out publickey.pem -subj '/'

            key = OpenSSL::PKey::RSA.new(2048)
            open( "#{options[:private_key_dir]}/private_key.pkcs7.pem", "w" ) do |io|
              io.write(key.to_pem)
            end

            puts "#{options[:private_key_dir]}/private_key.pkcs7.pem created."

            name = OpenSSL::X509::Name.parse("/")
            cert = OpenSSL::X509::Certificate.new()
            cert.serial = 0
            cert.version = 2
            cert.not_before = Time.now
            cert.not_after = Time.now + 50 * 365 * 24 * 60 * 60
            cert.public_key = key.public_key

            ef = OpenSSL::X509::ExtensionFactory.new
            ef.subject_certificate = cert
            ef.issuer_certificate = cert
            cert.extensions = [
              ef.create_extension("basicConstraints","CA:TRUE", true),
              ef.create_extension("subjectKeyIdentifier", "hash"),
              # ef.create_extension("keyUsage", "cRLSign,keyCertSign", true),
            ]
            cert.add_extension ef.create_extension("authorityKeyIdentifier",
                                                   "keyid:always,issuer:always")

            cert.sign key, OpenSSL::Digest::SHA1.new

            open( "#{options[:public_key_dir]}/public_key.pkcs7.pem", "w" ) do |io|
              io.write(cert.to_pem)
            end

            puts "#{options[:public_key_dir]}/public_key.pkcs7.pem created."

          end

        end

      end

    end

  end

end