require 'hiera/backend/eyaml'
require 'hiera/backend/eyaml/subcommand'
require 'hiera/backend/eyaml/subcommands'

class Hiera
  module Backend
    module Eyaml
      module Subcommands

        class Help < Eyaml::Subcommand

          def self.usage
            <<-EOS
Usage:
eyaml subcommand [global-opts] [subcommand-opts]

Available subcommands:
#{Eyaml::Subcommands.collect {|name, klass|
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