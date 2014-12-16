require 'trollop'
require 'hiera/backend/eyaml'
require 'hiera/backend/eyaml/utils'
require 'hiera/backend/eyaml/plugins'
require 'hiera/backend/eyaml/options'
require 'hiera/backend/eyaml/subcommand'
require 'hiera/backend/eyaml/subcommands'

class Hiera
  module Backend
    module Eyaml
      class CLI

        def self.parse
          Eyaml::Subcommands.find_all

          subcommand_arg = ARGV.shift.to_s.downcase
          Eyaml::Subcommands.input = subcommand_arg

          if Eyaml::Subcommands.names.member? subcommand_arg
            subcommand = subcommand_arg
          elsif subcommand_arg.match(/^\-/)
            subcommand = 'help'
            ARGV.clear
          else
            subcommand = 'unknown_command'
            ARGV.clear
          end

          command_class = Eyaml::Subcommands.find_and_use subcommand

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
