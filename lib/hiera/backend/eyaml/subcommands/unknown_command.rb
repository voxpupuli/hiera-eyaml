require 'hiera/backend/eyaml/subcommand'
require 'hiera/backend/eyaml/subcommands'
require 'hiera/backend/eyaml/subcommands/help'

class Hiera
  module Backend
    module Eyaml
      module Subcommands

        class UnknownCommand < Eyaml::Subcommand

          def self.message
            "Unknown subcommand: #{Eyaml::Subcommands.input.to_s}"
          end

          def self.options
            []
          end

          def self.description
            self.message
          end

          def self.execute
            puts "#{self.message}\n\n#{Eyaml::Subcommands::Help.usage}"
          end

          def self.hidden?
            true
          end

        end

      end
    end
  end
end
