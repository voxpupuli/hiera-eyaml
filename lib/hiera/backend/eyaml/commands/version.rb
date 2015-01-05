require 'hiera/backend/eyaml'
require 'hiera/backend/eyaml/commands/command'

class Hiera
  module Backend
    module Eyaml
      module Commands

        class Version < Eyaml::Commands::Command

          def self.options
            []
          end

          def self.description
            "show version information"
          end

          def self.execute
            plugin_versions = {}

            Eyaml::Utils.info "hiera-eyaml (core): #{Eyaml::VERSION}"

            Plugins.plugins.each do |plugin|
              plugin_shortname = plugin.name.split("hiera-eyaml-").last
              plugin_version = begin
                Encryptor.find(plugin_shortname)::VERSION.to_s
              rescue
                "unknown (is plugin compatible with eyaml 2.0+ ?)"
              end
              Eyaml::Utils.info "hiera-eyaml-#{plugin_shortname} (gem): #{plugin_version}"
            end

            nil
            
          end

        end

      end
    end
  end
end
