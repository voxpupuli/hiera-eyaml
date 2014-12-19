require 'hiera/backend/eyaml/utils'
require 'hiera/backend/eyaml/command'

class Hiera
  module Backend
    module Eyaml
      module Commands

        def self.names
          @@commands.keys
        end

        def self.classes
          @@commands.values
        end

        def self.class_for(command)
          @@commands[command]
        end

        def self.find_all
          @@commands = {}
          Eyaml::Utils.require_dir 'hiera/backend/eyaml/commands'
          Eyaml::Utils.find_all_subclasses_of(Eyaml::Command).collect { |klass|
            command = Eyaml::Utils.snakecase klass.name.split('::').last
            @@commands[command] = klass
          }
        end

        def self.find_and_use(command)
          begin
            require "hiera/backend/eyaml/commands/#{command}"
          rescue Exception
            require 'hiera/backend/eyaml/commands/unknown_command'
            return Eyaml::Commands::UnknownCommand
          end
          self.class_for command
        end

        def self.each &block
          @@commands.each &block
        end

        def self.collect
          values = []
          @@commands.each do |name, klass|
            values.push yield name, klass
          end
          values
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
