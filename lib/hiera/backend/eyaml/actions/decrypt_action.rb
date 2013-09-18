require 'hiera/backend/eyaml/utils'
require 'hiera/backend/eyaml/options'
require 'hiera/backend/eyaml/parser/parser'
require 'hiera/backend/eyaml/parser/encrypted_tokens'

class Hiera
  module Backend
    module Eyaml
      module Actions

        class DecryptAction

          REGEX_ENCRYPTED_BLOCK = />\n(\s*)ENC\[(\w+,)?([a-zA-Z0-9\+\/ =\n]+)\]/
          REGEX_ENCRYPTED_STRING = /ENC\[(\w+,)?([a-zA-Z0-9\+\/=]+)\]/

          def self.execute
            parser = Parser::ParserFactory.encrypted_parser
            tokens = parser.parse(Eyaml::Options[:input_data])
            case Eyaml::Options[:source]
              when :eyaml
                decrypted = tokens.map{ |token| token.to_decrypted }
                decrypted.join
              else
                decrypted = tokens.map{ |token|
                  case token.class.name
                    when /::EncToken$/#
                      token.plain_text
                    else
                      token.match
                  end
                }
                decrypted.join
            end

          end

        end

      end
    end
  end
end
