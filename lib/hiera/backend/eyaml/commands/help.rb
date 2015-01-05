require 'hiera/backend/eyaml'
require 'hiera/backend/eyaml/commands'
require 'hiera/backend/eyaml/commands/command'

class Hiera
  module Backend
    module Eyaml
      module Commands

        class Help < Eyaml::Commands::Command

          def self.usage
            <<-EOS
Usage:
eyaml command [global-opts] [command-opts]

Available commands:
#{Eyaml::Commands.collect {|name, klass|
  sprintf "%15s: %-65s", name.downcase, klass.description unless klass.hidden?
}.compact.join("\n")}

For more help on an individual command, use --help on that command

Installed Plugins:
#{Plugins.plugins.collect {|plugin|
  "\t" + plugin.name.split("hiera-eyaml-").last
}.join("\n")}
EOS
          end

          def self.options
            []
          end

          def self.description
            "this page"
          end

          def self.execute
            puts "Welcome to eyaml #{Eyaml::VERSION}\n\n#{self.usage}"
          end

          def self.hidden?
            true
          end

        end

      end
    end
  end
end