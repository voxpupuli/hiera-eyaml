require 'hiera/backend/eyaml/subcommand'
require 'hiera/backend/eyaml'

class Hiera
  module Backend
    module Eyaml
      module Subcommands

        class Version < Subcommand

          def self.options
            []
          end

          def self.description
            "show version information"
          end

          def self.execute

            puts <<-EOS
Version info

hiera-eyaml (core): #{Eyaml::VERSION}
#{Plugins.plugins.collect {|plugin| 
  plugin.name.split("hiera-eyaml-").last
}.collect {|plugin|
  "    hiera-eyaml-#{plugin} (gem): " + Encryptor.find(plugin)::VERSION.to_s
}.join("\n")}
EOS
          end

        end

      end
    end
  end
end