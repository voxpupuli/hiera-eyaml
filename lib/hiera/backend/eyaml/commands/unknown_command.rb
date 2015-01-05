require 'hiera/backend/eyaml/commands'
require 'hiera/backend/eyaml/commands/help'
require 'hiera/backend/eyaml/commands/command'

class Hiera
  module Backend
    module Eyaml
      module Commands

        class UnknownCommand < Eyaml::Commands::Command

          def self.message
            "Unknown command: #{Eyaml::Commands.input.to_s}"
          end

          def self.options
            []
          end

          def self.description
            self.message
          end

          def self.execute
            puts "#{self.message}\n\n#{Eyaml::Commands::Help.usage}"
          end

          def self.hidden?
            true
          end

        end

      end
    end
  end
end
