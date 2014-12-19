require 'trollop'
require 'hiera/backend/eyaml'
require 'hiera/backend/eyaml/utils'
require 'hiera/backend/eyaml/plugins'
require 'hiera/backend/eyaml/options'
require 'hiera/backend/eyaml/commands'

class Hiera
  module Backend
    module Eyaml
      class CLI

        def self.parse
          Eyaml::Commands.find_all

          command_arg = ARGV.shift.to_s.downcase
          Eyaml::Commands.input = command_arg

          if Eyaml::Commands.names.member? command_arg
            command = command_arg
          elsif command_arg.match(/^\-/)
            command = 'help'
            ARGV.clear
          else
            command = 'unknown_command'
            ARGV.clear
          end

          command_class = Eyaml::Commands.find_and_use command

          options = command_class.parse
          options[:executor] = command_class

          options = command_class.validate options
          Eyaml::Options.set options
          Eyaml::Options.trace

        end

        def self.execute

          executor = Eyaml::Options[:executor]
          begin
            result = executor.execute
            puts result unless result.nil?
          rescue Exception => e
            Utils.warn e.message
            Utils.debug e.backtrace.join("\n")
          end

        end

      end

    end

  end

end
