require 'hiera/backend/eyaml/subcommand'

class Hiera
  module Backend
    module Eyaml
      module Subcommands

        class Reencrypt < Subcommand

          def self.options
            []
          end

          def self.description
            "reencrypt an eyaml file"
          end

        end

      end
    end
  end
end
