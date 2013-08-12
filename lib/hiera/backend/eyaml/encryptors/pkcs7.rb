require 'openssl'
require 'hiera/backend/eyaml/encryptor'
require 'hiera/backend/eyaml/utils'

class Hiera
  module Backend
    module Eyaml
      module Encryptors

        class Pkcs7 < Encryptor

          @@encryptor_options = [
            { :name => :private_key_dir, :desc => "Private key directory", :type => :string, :default => "./keys" },
            { :name => :public_key_dir,  :desc => "Public key directory",  :type => :string, :default => "./keys" }
          ]

          @@encryptor_tag = "PKCS7"

          def encrypt plaintext

            public_key_pem = File.read( "#{options[:public_key_dir]}/public_key.pkcs7.pem" )
            public_key = OpenSSL::X509::Certificate.new( public_key_pem )

            cipher = OpenSSL::Cipher::AES.new(256, :CBC)
            OpenSSL::PKCS7::encrypt([public_key], plaintext, cipher, OpenSSL::PKCS7::BINARY).to_der
            
          end

          def decrypt ciphertext

            private_key_pem = File.read( "#{options[:private_key_dir]}/private_key.pkcs7.pem" )
            private_key = OpenSSL::PKey::RSA.new( private_key_pem )

            public_key_pem = File.read( "#{options[:public_key_dir]}/public_key.pkcs7.pem" )
            public_key = OpenSSL::X509::Certificate.new( public_key_pem )

            pkcs7 = OpenSSL::PKCS7.new( ciphertext )
            pkcs7.decrypt(private_key, public_key)

          end

          def create_keys

            # Try to do equivalent of:
            # openssl req -x509 -nodes -days 100000 -newkey rsa:2048 -keyout privatekey.pem -out publickey.pem -subj '/'

            key = OpenSSL::PKey::RSA.new(2048)
            Utils.write_important_file :filename => "#{options[:private_key_dir]}/private_key.pkcs7.pem", :content => key.to_pem

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
            ]
            cert.add_extension ef.create_extension("authorityKeyIdentifier",
                                                   "keyid:always,issuer:always")

            cert.sign key, OpenSSL::Digest::SHA1.new

            Utils.write_important_file :filename => "#{options[:private_key_dir]}/public_key.pkcs7.pem", :content => cert.to_pem
            puts "Keys created"

          end

        end

      end

    end

  end

end