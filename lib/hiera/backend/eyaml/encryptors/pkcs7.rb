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
            private_key: { desc: 'Path to private key',
                           type: :string,
                           default: './keys/private_key.pkcs7.pem', },
            public_key: { desc: 'Path to public key',
                          type: :string,
                          default: './keys/public_key.pkcs7.pem', },
            private_key_env_var: { desc: 'Name of environment variable to read private key from',
                                   type: :string, },
            public_key_env_var: { desc: 'Name of environment variable to read public key from',
                                  type: :string, },
            keysize: { desc: 'Key size used for encryption',
                       type: :integer,
                       default: 2048, },
          }

          self.tag = 'PKCS7'

          def self.encrypt(plaintext)
            LoggingHelper.trace 'PKCS7 encrypt'

            public_key_pem = self.load_public_key_pem()
            if /BEGIN CERTIFICATE/.match(public_key_pem) != nil
              public_key_x509 = OpenSSL::X509::Certificate.new(public_key_pem)
            elsif /BEGIN PUBLIC KEY/.match(public_key_pem) != nil
              public_key_rsa = OpenSSL::PKey::RSA.new(public_key_pem)
              public_key_x509 = OpenSSL::X509::Certificate.new
              public_key_x509.public_key = public_key_rsa.public_key
            end

            cipher = OpenSSL::Cipher.new('aes-256-cbc')
            OpenSSL::PKCS7.encrypt([public_key_x509], plaintext, cipher, OpenSSL::PKCS7::BINARY).to_der
          end

          def self.decrypt(ciphertext)
            LoggingHelper.trace 'PKCS7 decrypt'

            private_key_pem = self.load_private_key_pem()
            private_key_rsa = OpenSSL::PKey::RSA.new(private_key_pem)

            pkcs7 = OpenSSL::PKCS7.new(ciphertext)

            # Since ruby-openssl 2.2.0, it is possible to call OpenSSL::PKCS7#decrypt
            # with the private key only. Reference:
            # https://github.com/ruby/openssl/pull/183
            if Gem::Version::new(OpenSSL::VERSION) >= Gem::Version::new('2.2.0')
              public_key_x509 = nil
            else
              public_key_x509 = OpenSSL::X509::Certificate.new
              public_key_x509.serial = pkcs7.recipients[0].serial
              public_key_x509.public_key = private_key_rsa.public_key
            end

            pkcs7.decrypt(private_key_rsa, public_key_x509)
          end

          def self.create_keys
            # Equivalent of:
            # openssl genrsa -out private_key.pem 2048
            # openssl rsa -in private_key.pem -pubout -out public_key.pem
            private_key = option :private_key
            public_key = option :public_key
            keysize = option :keysize

            key = OpenSSL::PKey::RSA.new(keysize)
            EncryptHelper.ensure_key_dir_exists private_key
            EncryptHelper.write_important_file filename: private_key, content: key.to_pem, mode: 0o600

            EncryptHelper.ensure_key_dir_exists public_key
            EncryptHelper.write_important_file filename: public_key, content: key.public_key.to_pem
            LoggingHelper.info 'Keys created OK'
          end

          protected

          def self.load_ANY_key_pem(optname_key, optname_env_var)
            opt_key = option (optname_key.to_sym)
            opt_key_env_var = option (optname_env_var.to_sym)

            if opt_key and opt_key_env_var
              warn "both #{optname_key} and #{optname_env_var} specified, using #{optname_env_var}"
            end

            if opt_key_env_var
              raise StandardError, "env #{opt_key_env_var} is not set" unless ENV[opt_key_env_var]
              opt_key_pem = ENV[opt_key_env_var]
            elsif opt_key
              raise StandardError, "file #{opt_key} does not exist" unless File.exist? opt_key
              opt_key_pem = File.read opt_key
            else
              raise StandardError, "pkcs7_#{optname_key} is not defined" unless opt_key or opt_key_env_var
            end

            return opt_key_pem
          end

          def self.load_public_key_pem
            return self.load_ANY_key_pem('public_key', 'public_key_env_var')
          end

          def self.load_private_key_pem
            return self.load_ANY_key_pem('private_key', 'private_key_env_var')
          end

        end
      end
    end
  end
end
