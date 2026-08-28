require 'openssl'
require 'base64'
require 'securerandom'
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
            b64_private_key_env_var: { desc: 'Name of environment variable to read private key from, encoded in base64',
                                       type: :string, },
            b64_public_key_env_var: { desc: 'Name of environment variable to read public key from, encoded in base64',
                                      type: :string, },
            keysize: { desc: 'Key size used for encryption',
                       type: :integer,
                       default: 2048, },
          }

          self.tag = 'PKCS7'

          def self.encrypt(plaintext)
            LoggingHelper.trace 'PKCS7 encrypt'

            public_key_pem = load_public_key_pem
            if public_key_pem.include? 'BEGIN CERTIFICATE'
              public_key_x509 = load_certificate(public_key_pem)
            elsif public_key_pem.include? 'BEGIN PUBLIC KEY'
              public_key_rsa = OpenSSL::PKey::RSA.new(public_key_pem)
              public_key_x509 = OpenSSL::X509::Certificate.new
              public_key_x509.public_key = public_key_rsa.public_key
            else
              raise StandardError, "file #{public_key_pem} cannot be used to encrypt - invalid public key format"
            end

            cipher = OpenSSL::Cipher.new('aes-256-cbc')
            OpenSSL::PKCS7.encrypt([public_key_x509], plaintext, cipher, OpenSSL::PKCS7::BINARY).to_der
          end

          # Certificates written by hiera-eyaml 5.0.1 and earlier have an empty
          # subject and issuer DN, because create_keys never set them. Bouncy
          # Castle >= 1.85, which backs JRuby's OpenSSL implementation, and
          # therefore Puppet Server, refuses to parse a certificate with an
          # empty issuer, so encryption fails against every key pair generated
          # before that was fixed. Fill in the empty DNs and re-parse in that
          # case, so existing key pairs keep working on every Ruby engine.
          def self.load_certificate(public_key_pem)
            named_pem = name_empty_certificate_dns(public_key_pem)
            return OpenSSL::X509::Certificate.new(public_key_pem) if named_pem.nil?

            LoggingHelper.warn 'public key certificate has an empty subject and issuer, which newer ' \
                               "TLS stacks reject.\nReissue it from your existing private key (this " \
                               "keeps already-encrypted data readable):\n" \
                               'openssl req -x509 -key private_key.pkcs7.pem -subj "/CN=eyaml" ' \
                               '-days 18250 -out public_key.pkcs7.pem'
            named_pem
          end

          # Returns a copy of the given certificate with any empty subject and
          # issuer DN replaced by CN=eyaml, or nil when the certificate has a
          # non-empty issuer and so can simply be parsed as-is. Only the DNs are
          # rewritten: the public key, serial number and validity all carry over,
          # and the (now unverifiable) signature is left untouched, since a PKCS7
          # recipient certificate is never validated - it only supplies the
          # public key and the issuer/serial pair identifying the recipient.
          def self.name_empty_certificate_dns(public_key_pem)
            base64 = public_key_pem[/-----BEGIN CERTIFICATE-----(.*?)-----END CERTIFICATE-----/m, 1]
            return nil if base64.nil?

            certificate = OpenSSL::ASN1.decode(Base64.decode64(base64)).value
            # TBSCertificate ::= SEQUENCE { [0] version OPTIONAL, serialNumber,
            # signature, issuer, validity, subject, subjectPublicKeyInfo, ... }
            tbs_certificate = certificate[0].value
            offset = (tbs_certificate[0].tag_class == :CONTEXT_SPECIFIC && tbs_certificate[0].tag.zero?) ? 1 : 0
            issuer = tbs_certificate[offset + 2]
            subject = tbs_certificate[offset + 4]
            return nil unless issuer.value.empty?

            name = OpenSSL::ASN1.decode(OpenSSL::X509::Name.parse('/CN=eyaml').to_der)
            tbs_certificate[offset + 2] = name
            tbs_certificate[offset + 4] = name if subject.value.empty?
            der = OpenSSL::ASN1::Sequence.new([OpenSSL::ASN1::Sequence.new(tbs_certificate),
                                               certificate[1], certificate[2],]).to_der
            OpenSSL::X509::Certificate.new(der)
          rescue StandardError
            # Not a certificate shape we know how to repair - hand it back to the
            # normal parse path so that reports the problem.
            nil
          end

          def self.decrypt(ciphertext)
            LoggingHelper.trace 'PKCS7 decrypt'

            private_key_pem = load_private_key_pem
            private_key_rsa = OpenSSL::PKey::RSA.new(private_key_pem)

            pkcs7 = OpenSSL::PKCS7.new(ciphertext)

            public_key_x509 = OpenSSL::X509::Certificate.new
            public_key_x509.serial = pkcs7.recipients[0].serial
            public_key_x509.issuer = pkcs7.recipients[0].issuer
            public_key_x509.public_key = private_key_rsa.public_key

            pkcs7.decrypt(private_key_rsa, public_key_x509)
          end

          def self.create_keys
            # Do equivalent of:
            # openssl req -x509 -nodes -newkey rsa:2048 -keyout privatekey.pem -out publickey.pem -batch

            public_key = option :public_key
            private_key = option :private_key
            keysize = option :keysize

            key = OpenSSL::PKey::RSA.new(keysize)
            EncryptHelper.ensure_key_dir_exists private_key
            EncryptHelper.write_important_file filename: private_key, content: key.to_pem, mode: 0o600

            cert = OpenSSL::X509::Certificate.new
            # In JRuby implementation of openssl, not_before and not_after
            # are required to sign cert with key and digest. Signing the
            # certificate is only required for Ruby 2.7 to call cert.to_pem.
            cert.not_before = Time.now
            cert.not_after = if 1.size == 8 # 64bit
                               Time.now + (50 * 365 * 24 * 60 * 60)
                             else # 32bit
                               Time.at(0x7fffffff)
                             end
            # A v1 certificate with serial 0 is not RFC 5280 conformant, and
            # strict TLS stacks have been tightening up on both. Emit a v3
            # certificate with a random 19 byte serial, like `openssl req -x509`.
            cert.version = 2
            cert.serial = OpenSSL::BN.new(SecureRandom.hex(19), 16)
            cert.public_key = key.public_key
            # subject/issuer must be set before signing: JRuby's OpenSSL binding
            # (backed by BouncyCastle >= 1.85) rejects signing a certificate with
            # an empty issuer DN. Self-signed, so subject and issuer are the same.
            name = OpenSSL::X509::Name.parse('/CN=eyaml')
            cert.subject = name
            cert.issuer = name
            cert.sign key, OpenSSL::Digest.new('SHA256')

            EncryptHelper.ensure_key_dir_exists public_key
            EncryptHelper.write_important_file filename: public_key, content: cert.to_pem
            LoggingHelper.info 'Keys created OK'
          end

          def self.load_ANY_key_pem(optname_key, optname_env_var, b64_optname_env_var)
            opt_key = option(optname_key.to_sym)
            opt_key_env_var = option(optname_env_var.to_sym)
            b64_opt_key_env_var = option(b64_optname_env_var.to_sym)

            if opt_key and opt_key_env_var
              warn "both #{optname_key} and #{optname_env_var} specified, using #{optname_env_var}"
            end

            if opt_key_env_var
              raise StandardError, "env #{opt_key_env_var} is not set" unless ENV[opt_key_env_var]

              opt_key_pem = ENV.fetch(opt_key_env_var, nil)
            elsif b64_opt_key_env_var
              raise StandardError, "env #{b64_opt_key_env_var} is not set" unless ENV[b64_opt_key_env_var]

              opt_key_pem = Base64.decode64(ENV.fetch(b64_opt_key_env_var, nil))
            elsif opt_key
              raise StandardError, "file #{opt_key} does not exist" unless File.exist? opt_key

              opt_key_pem = File.read opt_key
            else
              raise StandardError, "pkcs7_#{optname_key} is not defined" unless opt_key or opt_key_env_var
            end

            opt_key_pem
          end

          def self.load_public_key_pem
            load_ANY_key_pem('public_key', 'public_key_env_var', 'b64_public_key_env_var')
          end

          def self.load_private_key_pem
            load_ANY_key_pem('private_key', 'private_key_env_var', 'b64_private_key_env_var')
          end
        end
      end
    end
  end
end
