require 'openssl'
require 'hiera/backend/eyaml/encryptor'
require 'hiera/backend/eyaml/encrypthelper'
require 'hiera/backend/eyaml/logginghelper'
require 'hiera/backend/eyaml/options'

class Hiera
  module Backend
    module Eyaml
      module Encryptors

        class Pkcs7 < Encryptor

          self.options = {
            :private_key => { :desc => "Path to private key", 
                              :type => :string, 
                              :default => "./keys/private_key.pkcs7.pem" },
            :public_key => { :desc => "Path to public key",  
                             :type => :string, 
                             :default => "./keys/public_key.pkcs7.pem" },
            :subject => { :desc => "Subject to use for certificate when creating keys",
                          :type => :string,
                          :default => "/" },
          }

          self.tag = "PKCS7"

          def self.encrypt plaintext

            public_key = self.option :public_key
            raise StandardError, "pkcs7_public_key is not defined" unless public_key

            public_key_pem = File.read public_key 
            public_key_x509 = OpenSSL::X509::Certificate.new( public_key_pem )

            cipher = OpenSSL::Cipher::AES.new(256, :CBC)
            OpenSSL::PKCS7::encrypt([public_key_x509], plaintext, cipher, OpenSSL::PKCS7::BINARY).to_der
            
          end

          def self.decrypt ciphertext

            public_key = self.option :public_key
            private_key = self.option :private_key
            raise StandardError, "pkcs7_public_key is not defined" unless public_key
            raise StandardError, "pkcs7_private_key is not defined" unless private_key

            private_key_pem = File.read private_key
            private_key_rsa = OpenSSL::PKey::RSA.new( private_key_pem )

            public_key_pem = File.read public_key
            public_key_x509 = OpenSSL::X509::Certificate.new( public_key_pem )

            pkcs7 = OpenSSL::PKCS7.new( ciphertext )
            pkcs7.decrypt(private_key_rsa, public_key_x509)

          end

          def self.create_keys

            # Try to do equivalent of:
            # openssl req -x509 -nodes -days 100000 -newkey rsa:2048 -keyout privatekey.pem -out publickey.pem -subj '/'

            public_key = self.option :public_key
            private_key = self.option :private_key
            subject = self.option :subject

            key = OpenSSL::PKey::RSA.new(2048)
            EncryptHelper.ensure_key_dir_exists private_key
            EncryptHelper.write_important_file :filename => private_key, :content => key.to_pem, :mode => 0600

            cert = OpenSSL::X509::Certificate.new()
            cert.subject = OpenSSL::X509::Name.parse(subject)
            cert.serial = 1
            cert.version = 2
            cert.not_before = Time.now
            cert.not_after = if 1.size == 8       # 64bit
              Time.now + 50 * 365 * 24 * 60 * 60
            else                                  # 32bit
              Time.at(0x7fffffff)
            end
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

            EncryptHelper.ensure_key_dir_exists public_key
            EncryptHelper.write_important_file :filename => public_key, :content => cert.to_pem
            LoggingHelper.info "Keys created OK"

          end

        end

      end

    end

  end

end