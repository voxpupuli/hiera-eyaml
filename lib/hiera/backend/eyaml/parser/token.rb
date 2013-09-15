class Hiera
  module Backend
    module Eyaml
      module Parser
        class TokenType
          attr_reader :regex
          attr_reader :name
          def createToken input
            raise 'Abstract method called'
          end
        end

        class Token
          attr_reader :type
        end
      end
    end
  end
end