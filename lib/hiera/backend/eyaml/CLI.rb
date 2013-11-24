require 'trollop'
require 'hiera/backend/eyaml'
require 'hiera/backend/eyaml/utils'
require 'hiera/backend/eyaml/plugins'
require 'hiera/backend/eyaml/options'
require 'hiera/backend/eyaml/subcommand'

class Hiera
  module Backend
    module Eyaml
      class CLI

        def self.parse

          Utils.require_dir 'hiera/backend/eyaml/subcommands'
          Eyaml.subcommands = Utils.find_all_subclasses_of({ :parent_class => Hiera::Backend::Eyaml::Subcommands }).collect {|classname| Utils.snakecase classname}

          Eyaml.subcommand = ARGV.shift
          subcommand = case Eyaml.subcommand
          when nil
            ARGV.delete_if {true}
            "unknown_command"
          when /^\-/
            ARGV.delete_if {true}
            "help"
          else
            Eyaml.subcommand
          end

          command_class = Subcommand.find subcommand

          options = command_class.parse
          options[:executor] = command_class

          # options.merge! command.parse
          # options[:action] = command.to_sym


          # options[:source] = :not_applicable if options[:action] == :createkeys

          # Trollop::die "Nothing to do" if options[:source].nil? or options[:action].nil?

          # options[:input_data] = case options[:source]
          # when :stdin
          #   STDIN.read
          # when :password
          #   Utils.read_password
          # when :string
          #   options[:string]
          # when :file
          #   File.read options[:file]
          # when :eyaml
          #   File.read options[:eyaml]
          # when :stdin
          #   STDIN.read
          # else
          #   if options[:edit]
          #     options[:eyaml] = options[:edit]
          #     options[:source] = :eyaml
          #     File.read options[:edit] 
          #   else
          #     nil
          #   end
          # end

          # Eyaml.default_encryption_scheme = options[:encrypt_method].upcase if options[:encrypt_method]
          Eyaml::Options.set options
          Eyaml::Options.debug

        end

        def self.execute

          executor = Eyaml::Options[:executor]
          begin
            result = executor.execute
            puts result unless result.nil?
          rescue Exception => e
            Utils.warn e.message
            Utils.info e.backtrace.inspect
          end

        end          

      end

    end

  end

end
