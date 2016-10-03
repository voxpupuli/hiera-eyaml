require 'openssl'
require 'vault'
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
            :private_key   => { :desc    => "Path to private key",
                                :type    => :string,
                                :default => "./keys/private_key.pkcs7.pem" },
            :public_key    => { :desc    => "Path to public key",
                                :type    => :string,
                                :default => "./keys/public_key.pkcs7.pem" },
            :subject       => { :desc    => "Subject to use for certificate when creating keys",
                                :type    => :string,
                                :default => "/" },
            :vault_appid   => { :desc    => "Vault Application ID",
                                :type    => :string,
                                :default => "" },
            :vault_userid  => { :desc    => "Path to Vault User ID",
                                :type    => :string,
                                :default => "" },
            :vault_address => { :desc    => "Vault Server Address",
                                :type    => :string,
                                :defualt => "" }
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
            if public_key.start_with?('VAULT') or private_key.start_with?('VAULT') then
              vault_appid = self.option :vault_appid
              vault_userid = File.read(self.option :vault_userid)
              vault_address = self.option :vault_address

              raise StandardError, "Trying to use Vault without Authentication" unless vault_appid and vault_userid and vault_address

              Vault.address = vault_address
              Vault.auth.app_id vault_appid, vault_userid unless @private_key_rsa
            end

            if not defined?(@private_key_rsa) then
              if private_key.start_with?('VAULT') then
                path, key = private_key.match(/VAULT\[([^:]*):([^\]]*)\]/).captures
                private_key_pem = Vault.logical.read(path).data[key.to_sym()]
              else
                private_key_pem = File.read private_key unless @private_key_rsa
              end
            end
            @private_key_rsa ||= OpenSSL::PKey::RSA.new( private_key_pem )

            if not defined?(@public_key_x509) then
              if public_key.start_with?('VAULT') then
                path, key = public_key.match(/VAULT\[([^:]*):([^\]]*)\]/).captures
                public_key_pem = Vault.logical.read(path).data[key.to_sym()]
              else
                public_key_pem = File.read public_key unless @public_key_x509
              end
            end
            @public_key_x509 ||= OpenSSL::X509::Certificate.new( public_key_pem )

            pkcs7 = OpenSSL::PKCS7.new( ciphertext )
            pkcs7.decrypt(@private_key_rsa, @public_key_x509)

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
