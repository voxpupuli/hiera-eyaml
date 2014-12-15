require 'hiera/backend/eyaml/utils'
require 'hiera/backend/eyaml/subcommand'

class Hiera
  module Backend
    module Eyaml
      module Subcommands

        def self.names
          @@subcommands.keys
        end

        def self.classes
          @@subcommands.values
        end

        def self.class_for(subcommand)
          @@subcommands[subcommand]
        end

        def self.parse
          @@subcommands = {}
          Utils.require_dir 'hiera/backend/eyaml/subcommands'
          Utils.find_all_subclasses_of(Hiera::Backend::Eyaml::Subcommand).collect { |klass|
            subcommand = klass.name.split('::').last.downcase
            @@subcommands[subcommand] = klass
          }
        end

        def self.input= command
          @@input = command
        end

        def self.input
          @@input
        end

      end
    end
  end
end
