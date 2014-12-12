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

        def self.register_options(args)
          options = args[:options]
          plugin = args[:plugin]
          options.each do |name, option_hash|
            option_name = "#{plugin}_#{name}"
            new_option = {:name => option_name}
            new_option.merge! option_hash
            Hiera::Backend::Eyaml::Utils.warn "Duplicate option #{name} for #{plugin} plugin" if option_exists? option_name
            @@options << new_option
          end
        end

        def self.find
          gem_specs = Hiera::Backend::Eyaml::Utils.find_gem_specs
          gem_specs.each { |gem_spec|
            next if @@plugins.include? gem_spec

            file = Hiera::Backend::Eyaml::Utils.find_file_in_gem gem_spec, '**/eyaml_init.rb'
            next unless file

            @@plugins << gem_spec
            load file
          }
          @@plugins
        end

        def self.option_exists?(option_name)
          @@options.select { |option| option[:name] == option_name }.count > 0
        end
        private_class_method :option_exists?

      end
    end
  end
end
