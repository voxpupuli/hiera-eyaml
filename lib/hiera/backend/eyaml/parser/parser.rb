require 'strscan'

class Hiera
  module Backend
    module Eyaml
      module Parser
        class Parser
          attr_reader :token_types
          def self.initialize(token_types)
            @token_types = token_types
          end

          def self.parse text
            # Find the first match of any regex in the text
            # If any regex matches on 1, then return that match plus a recursive call on the remaining text
            # If no regex matches on 1 then return the block of text to the earliest match and a recursive call on the remaining text
            result = []
            s = StringScanner.new(text)
            first_match = @token_types.find { |token|
              s.match?(token.regex)
            }
            unless first_match.nil?
              match_data = s.scan(first_match.regex)
              result << [first_match, match_data]
            end

            first_index.find_index{|position| 1.eql? position }

            positions = @token_types.map { |regex|
              match = regex.match(text)
              if match.nil?
                [regex, nil]
              else
                [regex, match.begin(0)]
              end
            }
            first_match = positions.find { |(regex, match)| 0.eql? match }
            unless first_match.nil?

            end
          end

        end
      end
    end
  end
end