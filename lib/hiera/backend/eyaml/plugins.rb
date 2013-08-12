require 'rubygems'

class Hiera
  module Backend
    module Eyaml
      class Plugins

        @@plugins = []
        @@options = {}

        def self.register_options args
          options_hash = args[ :options ]
          plugin = args[ :plugin ]
          options_hash.each do |key, value|
            @@options.merge!({ "#{plugin}-#{key}" => value })
          end
        end

        def self.options
          @@options
        end

        def self.find

          this_version = Gem::Version.create(Hiera::Backend::Eyaml::VERSION)
          index = Gem::VERSION >= "1.8.0" ? Gem::Specification : Gem.source_index

          [index].flatten.each do |source|
            specs = Gem::VERSION >= "1.6.0" ? source.latest_specs(true) : source.latest_specs

            specs.each do |spec|
              next if @@plugins.include? spec

              # If this gem depends on Vagrant, verify this is a valid release of
              # Vagrant for this gem to load into.
              dependency = spec.dependencies.find { |d| d.name == "hiera-eyaml" }
              next if dependency && !dependency.requirement.satisfied_by?( this_version )

              file = nil
              if Gem::VERSION >= "1.8.0"
                file = spec.matches_for_glob("**/eyaml_init.rb").first
              else
                file = Gem.searcher.matching_files(spec, "eyaml_init.rb").first
              end

              next unless file

              @@plugins << spec
              load file
            end

          end

          @@plugins

        end

        def self.plugins
          @@plugins
        end

      end
    end
  end
end
