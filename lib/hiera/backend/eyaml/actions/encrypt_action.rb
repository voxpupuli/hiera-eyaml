require 'hiera/backend/eyaml/options'
require 'hiera/backend/eyaml/parser/parser'
require 'hiera/backend/eyaml/parser/encrypted_tokens'

class Hiera
  module Backend
    module Eyaml
      module Actions
        class EncryptAction

          def self.execute 
            case Eyaml::Options[:source]
              when :eyaml
                parser = Parser::ParserFactory.decrypted_parser
                tokens = parser.parse(Eyaml::Options[:input_data])
                encrypted = tokens.map{ |token| token.to_encrypted }
                encrypted.join
              else
                encryptor = Encryptor.find
                ciphertext = encryptor.encode( encryptor.encrypt(Eyaml::Options[:input_data]) )
                token = Parser::EncToken.new(:block, Eyaml::Options[:input_data], encryptor, ciphertext, nil, '    ')
                case Eyaml::Options[:output]
                  when "block"
                    token.to_encrypted :label => Eyaml::Options[:label], :use_chevron => !Eyaml::Options[:label].nil?, :format => :block
                  when "string"
                    token.to_encrypted :label => Eyaml::Options[:label], :format => :string
                  when "examples"
                    string = token.to_encrypted :label => Eyaml::Options[:label] || 'string', :format => :string
                    block = token.to_encrypted :label => Eyaml::Options[:label] || 'block', :format => :block
                    "#{string}\n\nOR\n\n#{block}"
                  else
                    token.to_encrypted :format => :string
                end
            end
          end

        end
      end
    end
  end
end
