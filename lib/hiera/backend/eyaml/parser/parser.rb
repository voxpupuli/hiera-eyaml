require 'strscan'
require 'hiera/backend/eyaml/parser/token'
require 'hiera/backend/eyaml/parser/encrypted_tokens'

class Hiera
  module Backend
    module Eyaml
      module Parser
        class ParserFactory
          def self.encrypted_parser
            enc_string = EncStringTokenType.new()
            enc_block = EncBlockTokenType.new()
            Parser.new([enc_string, enc_block])
          end

          def self.decrypted_parser
            dec_string = DecStringTokenType.new()
            dec_block = DecBlockTokenType.new()
            Parser.new([dec_string, dec_block])
          end

          def self.hiera_backend_parser
            enc_hiera = EncHieraTokenType.new()
            Parser.new([enc_hiera])
          end
        end

        class Parser
          attr_reader :token_types

          def initialize(token_types)
            @token_types = token_types
          end

          def parse text
            parse_scanner(StringScanner.new(text)).reverse
          end

          def parse_scanner s
            if s.eos?
              []
            else
              # Check if the scanner currently matches a regex
              current_match = @token_types.find { |token_type|
                s.match?(token_type.regex)
              }

              token =
                  if current_match.nil?
                    # No regex matches here. Find the earliest match.
                    next_match_indexes = @token_types.map { |token_type|
                      next_match = s.check_until(token_type.regex)
                      if next_match.nil?
                        nil
                      else
                        next_match.length - s.matched.length
                      end
                    }.reject { |i| i.nil? }
                    non_match_size =
                        if next_match_indexes.length == 0
                          s.rest_size
                        else
                          next_match_indexes.min
                        end
                    non_match = s.peek(non_match_size)
                    # advance scanner
                    s.pos = s.pos + non_match_size
                    NonMatchToken.new(non_match)
                  else
                    # A regex matches so create a token and do a recursive call with the advanced scanner
                    current_match.create_token s.scan(current_match.regex)
                  end

              self.parse_scanner(s) << token
            end
          end

        end
      end
    end
  end
end