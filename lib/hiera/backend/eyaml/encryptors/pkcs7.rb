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
            :private_key_env_var => { :desc => "Name of environment variable to read private key from",
                                      :type => :string },
            :public_key_env_var => { :desc => "Name of environment variable to read public key from",
                                      :type => :string },
            :subject => { :desc => "Subject to use for certificate when creating keys",
                          :type => :string,
                          :default => "/" },
            :keysize => { :desc => "Key size used for encryption",
                          :type => :integer,
                          :default => 2048 },
            :digest  => { :desc => "Hash function used for PKCS7",
                          :type => :string,
                          :default => "SHA256"},
          }

          self.tag = "PKCS7"

          def self.encrypt plaintext

            LoggingHelper::trace 'PKCS7 encrypt'

            public_key = self.option :public_key
            public_key_env_var = self.option :public_key_env_var
            raise StandardError, "pkcs7_public_key is not defined" unless public_key or public_key_env_var

            if public_key and public_key_env_var
              warn "both public_key and public_key_env_var specified, using public_key"
            end

            if public_key_env_var and ENV[public_key_env_var]
              public_key_pem = ENV[public_key_env_var]
            else
              public_key_pem = File.read public_key
            end
            public_key_x509 = OpenSSL::X509::Certificate.new( public_key_pem )

            cipher = OpenSSL::Cipher::AES.new(256, :CBC)
            OpenSSL::PKCS7::encrypt([public_key_x509], plaintext, cipher, OpenSSL::PKCS7::BINARY).to_der
          end

          def self.decrypt ciphertext

            LoggingHelper::trace 'PKCS7 decrypt'

            public_key = self.option :public_key
            private_key = self.option :private_key
            public_key_env_var = self.option :public_key_env_var
            private_key_env_var = self.option :private_key_env_var
            raise StandardError, "pkcs7_public_key is not defined" unless public_key or public_key_env_var
            raise StandardError, "pkcs7_private_key is not defined" unless private_key or private_key_env_var

            if public_key and public_key_env_var
              warn "both public_key and public_key_env_var specified, using public_key"
            end
            if private_key and private_key_env_var
              warn "both private_key and private_key_env_var specified, using private_key"
            end

            if private_key_env_var and ENV[private_key_env_var]
              private_key_pem = ENV[private_key_env_var]
            else
              private_key_pem = File.read private_key
            end
            private_key_rsa = OpenSSL::PKey::RSA.new( private_key_pem )

            if public_key_env_var and ENV[public_key_env_var]
              public_key_pem = ENV[public_key_env_var]
            else
              public_key_pem = File.read public_key
            end
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
            keysize = self.option :keysize
            digest = self.option :digest

            key = OpenSSL::PKey::RSA.new(keysize)
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

            cert.sign key, OpenSSL::Digest.new(digest)

            EncryptHelper.ensure_key_dir_exists public_key
            EncryptHelper.write_important_file :filename => public_key, :content => cert.to_pem
            LoggingHelper.info "Keys created OK"

          end

        end

      end

    end

  end

end
