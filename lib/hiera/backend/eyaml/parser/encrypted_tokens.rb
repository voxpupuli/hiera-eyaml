require 'hiera/backend/eyaml/parser/token'
require 'hiera/backend/eyaml/utils'
require 'hiera/backend/eyaml/encryptor'
require 'hiera/backend/eyaml'


class Hiera
  module Backend
    module Eyaml
      module Parser
        class EncToken < Token
          attr_reader :format, :cipher, :encryptor, :indentation, :plain_text
          def self.encrypted_value(format, encryption_scheme, cipher, match, indentation = '')
            decryptor = Encryptor.find encryption_scheme
            plain_text = decryptor.decrypt( decryptor.decode cipher )
            EncToken.new(format, plain_text, decryptor, cipher, match, indentation)
          end
          def self.decrypted_value(format, plain_text, encryption_scheme, match, indentation = '')
            encryptor = Encryptor.find encryption_scheme
            cipher = encryptor.encode( encryptor.encrypt plain_text )
            EncToken.new(format, plain_text, encryptor, cipher, match, indentation)
          end

          def initialize(format, plain_text, encryptor, cipher, match = '', indentation = '')
            @format = format
            @plain_text = plain_text
            @encryptor = encryptor
            @cipher = cipher
            @indentation = indentation
            super(match)
          end

          def to_encrypted
            case @format
              when :block
                ciphertext = @cipher.gsub(/\n/, "\n" + @indentation)
                ">\n" + @indentation + "ENC[#{@encryptor.tag},#{ciphertext}]"
              when :string
                ciphertext = @cipher.gsub(/\n/, "")
                "ENC[#{@encryptor.tag},#{ciphertext}]"
              else
                raise "#{@format} is not a valid format"
            end
          end

          def to_decrypted
            case @format
              when :block
                ">\n" + indentation + "DEC::#{decryptor.tag}[" + plaintext + "]!"
              when :string
                "DEC::#{decryptor.tag}[" + plaintext + "]!"
              else
                raise "#{@format} is not a valid format"
            end
          end

        end

        class EncTokenType < TokenType
          def create_enc_token(match, enc_comma, cipher, indentation = '')
            encryption_scheme =
                if enc_comma.nil?
                  Eyaml.default_encryption_scheme
                else
                  enc_comma.split(",").first
                end
            EncToken.encrypted_value(:string, encryption_scheme, cipher, match, indentation)
          end
        end

        class EncStringTokenType < EncTokenType
          def initialize
            @regex = /ENC\[(\w+,)?([a-zA-Z0-9\+\/=]+)\]/
          end
          def create_token(string)
            @regex.match(string) { |m| self.create_enc_token(string, $1, $2) }
          end
        end

        class EncBlockTokenType < EncTokenType
          def initialize
            @regex = />\n(\s*)ENC\[(\w+,)?([a-zA-Z0-9\+\/ =\n]+)\]/
          end
          def create_token(string)
            @regex.match(string) { |m| self.create_enc_token(string, $2, $3, $1) }
          end
        end

        class DecStringTokenType < TokenType
          def initialize
            @regex = /DEC::(\w+)\[(.+)\]\!/
          end
          def create_token(string)
            @regex.match(string) { |m| EncToken.decrypted_value(:string, $2, $1, string) }
          end
        end

        class DecBlockTokenType < TokenType
          def initialize
            @regex = />\n(\s*)DEC::(\w+)\[(.+)\]\!/
          end
          def create_token(string)
            @regex.match(string) { |m| EncToken.decrypted_value(:block, $3, $2, string, $1) }
          end
        end

      end
    end
  end
end
