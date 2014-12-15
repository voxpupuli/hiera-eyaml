require 'hiera/backend/eyaml/subcommand'
require 'hiera/backend/eyaml/subcommands'

class Hiera
  module Backend
    module Eyaml
      module Subcommands

        class UnknownCommand < Eyaml::Subcommand

          class << self
            attr_accessor :original_command
          end

          @@original_command = "unknown"

          def self.options
            []
          end

          def self.description
            "Unknown command (#{@@original_command})"
          end

          def self.execute
            puts <<-EOS
Unknown subcommand#{ ": " + Eyaml::Subcommands.input if Eyaml::Subcommands.input }

Usage: eyaml <subcommand>

Please use one of the following subcommands or help for more help:
  #{Eyaml::Subcommands.names.sort.collect {|command|
  command_class = Eyaml::Subcommands.class_for command
  command unless command_class.hidden?
}.compact.join(", ")}
EOS
          end

          def self.hidden?
            true
          end

        end

      end
    end
  end
end
