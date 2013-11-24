require 'hiera/backend/eyaml/subcommand'

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
            subcommands = Eyaml.subcommands
            puts <<-EOS
Unknown subcommand#{ ": " + Eyaml.subcommand if Eyaml.subcommand }

Usage: eyaml <subcommand>

Please use one of the following subcommands or help for more help:
  #{Eyaml.subcommands.sort.collect {|command|
  command_class = Subcommands.const_get(Utils.camelcase command)
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
