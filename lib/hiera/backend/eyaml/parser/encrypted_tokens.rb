require 'hiera/backend/eyaml/parser/token'
require 'hiera/backend/eyaml/utils'
require 'hiera/backend/eyaml/encryptor'
require 'hiera/backend/eyaml'


class Hiera
  module Backend
    module Eyaml
      module Parser
        class EncToken < Token
          attr_reader :format, :cipher, :encryptor, :indentation, :plain_text, :id
          def self.encrypted_value(format, encryption_scheme, cipher, match, indentation = '')
            decryptor = Encryptor.find encryption_scheme
            plain_text = decryptor.decrypt( decryptor.decode cipher )
            EncToken.new(format, plain_text, decryptor, cipher, match, indentation)
          end
          def self.decrypted_value(format, plain_text, encryption_scheme, match, id, indentation = '')
            encryptor = Encryptor.find encryption_scheme
            cipher = encryptor.encode( encryptor.encrypt plain_text )
            id_number = id.nil? ? nil : id.gsub(/\(|\)/, "").to_i
            EncToken.new(format, plain_text, encryptor, cipher, match, indentation, id_number)
          end

          def initialize(format, plain_text, encryptor, cipher, match = '', indentation = '', id = nil)
            @format = format
            @plain_text = plain_text
            @encryptor = encryptor
            @cipher = cipher
            @indentation = indentation
            @id = id
            super(match)
          end

          def to_encrypted(args={})
            label = args[:label]
            label_string = label.nil? ? '' : "#{label}: "
            format = args[:format].nil? ? @format : args[:format]
            case format
              when :block
                # strip any white space
                @cipher = @cipher.gsub(/[ \t]/, "")
                # normalize indentation
                ciphertext = @cipher.gsub(/[\n\r]/, "\n" + @indentation)
                chevron = (args[:use_chevron].nil? || args[:use_chevron]) ? ">\n" : ''
                "#{label_string}#{chevron}" + @indentation + "ENC[#{@encryptor.tag},#{ciphertext}]"
              when :string
                ciphertext = @cipher.gsub(/[\n\r]/, "")
                "#{label_string}ENC[#{@encryptor.tag},#{ciphertext}]"
              else
                raise "#{@format} is not a valid format"
            end
          end

          def to_decrypted(args={})
            label = args[:label]
            label_string = label.nil? ? '' : "#{label}: "
            format = args[:format].nil? ? @format : args[:format]
            index = args[:index].nil? ? '' : "(#{args[:index]})"
            case format
              when :block
                chevron = (args[:use_chevron].nil? || args[:use_chevron]) ? ">\n" : ''
                "#{label_string}#{chevron}" + indentation + "DEC#{index}::#{@encryptor.tag}[" + @plain_text + "]!"
              when :string
                "#{label_string}DEC#{index}::#{@encryptor.tag}[" + @plain_text + "]!"
              else
                raise "#{@format} is not a valid format"
            end
          end

          def to_plain_text
            @plain_text
          end

        end

        class EncTokenType < TokenType
          def create_enc_token(match, type, enc_comma, cipher, indentation = '')
            encryption_scheme = enc_comma.nil? ? Eyaml.default_encryption_scheme : enc_comma.split(",").first
            EncToken.encrypted_value(type, encryption_scheme, cipher, match, indentation)
          end
        end

        class EncHieraTokenType < EncTokenType
          def initialize
            @regex = /ENC\[(\w+,)?([a-zA-Z0-9\+\/ =\n]+?)\]/
            @string_token_type = EncStringTokenType.new()
          end
          def create_token(string)
            @string_token_type.create_token(string.gsub(/\s/, ''))
          end
        end

        class EncStringTokenType < EncTokenType
          def initialize
            @regex = /ENC\[(\w+,)?([a-zA-Z0-9\+\/=]+?)\]/
          end
          def create_token(string)
            md = @regex.match(string)
            self.create_enc_token(string, :string, md[1], md[2])
          end
        end

        class EncBlockTokenType < EncTokenType
          def initialize
            @regex = />\n(\s*)ENC\[(\w+,)?([a-zA-Z0-9\+\/=\s]+?)\]/
          end
          def create_token(string)
            md = @regex.match(string)
            self.create_enc_token(string, :block, md[2], md[3], md[1])
          end
        end

        class DecStringTokenType < TokenType
          def initialize
            @regex = /DEC(\(\d+\))?::(\w+)\[(.+?)\]\!/m
          end
          def create_token(string)
            md = @regex.match(string)
            EncToken.decrypted_value(:string, md[3], md[2], string, md[1])
          end
        end

        class DecBlockTokenType < TokenType
          def initialize
            @regex = />\n(\s*)DEC(\(\d+\))?::(\w+)\[(.+?)\]\!/m
          end
          def create_token(string)
            md = @regex.match(string)
            EncToken.decrypted_value(:block, md[4], md[3], string, md[2], md[1])
            EncToken.decrypted_value(:block, md[4], md[3], string, md[2], md[1])
          end
        end

      end
    end
  end
end
