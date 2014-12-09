require 'rubygems'
require 'hiera/backend/eyaml/utils'

class Hiera
  module Backend
    module Eyaml
      class Plugins

        @@plugins = []
        @@commands = []
        @@options = []

        def self.options
          @@options
        end

        def self.plugins
          @@plugins
        end

        def self.commands
          @@commands
        end

        def self.register_options args
          options = args[ :options ]
          plugin = args[ :plugin ]
          options.each do |name, option_hash|
            option_name = "#{plugin}_#{name}"
            new_option = {:name => option_name}
            new_option.merge! option_hash
            Hiera::Backend::Eyaml::Utils.warn "Duplicate option #{name} for #{plugin} plugin" if self.option_exists? option_name
            @@options << new_option
          end
        end

        def self.option_exists? option_name
          @@options.select { |option| option[:name] == option_name }.count > 0
        end

        def self.find

          this_version = Gem::Version.create(Hiera::Backend::Eyaml::VERSION)
          index = Gem::VERSION >= "1.8.0" ? Gem::Specification : Gem.source_index

          [index].flatten.each do |source|
            specs = Gem::VERSION >= "1.6.0" ? source.latest_specs(true) : source.latest_specs

            specs.each do |spec|
              next if @@plugins.include? spec

              dependency = spec.dependencies.find { |d| d.name == "hiera-eyaml" }
              next if dependency && !dependency.requirement.satisfied_by?( this_version )

              file = nil
              if Gem::VERSION >= "1.8.0"
                file = spec.matches_for_glob("**/eyaml_init.rb").first
              else
                file = Gem.searcher.matching_files(spec, "**/eyaml_init.rb").first
              end

              next unless file

              @@plugins << spec
              load file
            end

          end

          @@plugins

        end

      end
    end
  end
end
