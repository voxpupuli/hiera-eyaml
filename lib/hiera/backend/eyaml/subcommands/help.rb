require 'hiera/backend/eyaml'
require 'hiera/backend/eyaml/subcommand'
require 'hiera/backend/eyaml/subcommands'

class Hiera
  module Backend
    module Eyaml
      module Subcommands

        class Help < Subcommand

          def self.options
            []
          end

          def self.description
            "this page"
          end

          def self.execute

            puts <<-EOS
Welcome to eyaml #{Eyaml::VERSION} 

Usage:
eyaml subcommand [global-opts] [subcommand-opts]

Available subcommands:
#{Eyaml::Subcommands.collect {|command|
  command_class = Eyaml::Subcommands.class_for command
  sprintf "%15s: %-65s", command.downcase, command_class.description unless command_class.hidden?
}.compact.join("\n")}

For more help on an individual command, use --help on that command

Installed Plugins:
#{Plugins.plugins.collect {|plugin| 
  "\t" + plugin.name.split("hiera-eyaml-").last
}.join("\n")}
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