require 'base64'
# require 'hiera/backend/eyaml/subcommands/unknown_command'

class Hiera
  module Backend
    module Eyaml

      class Subcommand

        class << self
          attr_accessor :global_options, :options, :helptext
        end

        @@global_options = [
           {:name          => :encrypt_method,
              :description => "Override default encryption and decryption method (default is PKCS7)", 
              :short       => 'n', 
              :default     => "pkcs7"},
           {:name          => :version,
              :description => "Show version information"},
           {:name          => :verbose,
              :description => "Be more verbose",
              :short       => 'v'},
           {:name          => :quiet,
              :description => "Be less verbose",
              :short       => 'q'},
           {:name          => :help,
              :description => "Information on how to use this command",
              :short       => 'h'}
          ]
        
        def self.options 
          @@global_options
        end

        def self.attach_option opt
          self.suboptions += opt
        end

        def self.find commandname = "unknown_command"
          begin
            require "hiera/backend/eyaml/subcommands/#{commandname.downcase}"
          rescue Exception => e
            require "hiera/backend/eyaml/subcommands/unknown_command"
            return Hiera::Backend::Eyaml::Subcommands::UnknownCommand
          end          
          command_module = Module.const_get('Hiera').const_get('Backend').const_get('Eyaml').const_get('Subcommands')
          command_class = Utils.find_closest_class :parent_class => command_module, :class_name => commandname
          command_class || Hiera::Backend::Eyaml::Subcommands::UnknownCommand
        end

        def self.parse

          options = Trollop::options do

            version "Hiera-eyaml version " + Hiera::Backend::Eyaml::VERSION.to_s
            banner [Hiera::Backend::Eyaml::DESCRIPTION].join("\n\n")

            @@global_options.each do |available_option|

              skeleton = {:description => "",
                          :short => :none}

              skeleton.merge! available_option
              opt skeleton[:name], 
                  skeleton[:description], 
                  :short => skeleton[:short], 
                  :default => skeleton[:default], 
                  :type => skeleton[:type]

            end

            stop_on Eyaml.subcommands

          end

          if options[:verbose]
            Hiera::Backend::Eyaml.verbosity_level += 1
          end

          if options[:quiet]
            Hiera::Backend::Eyaml.verbosity_level = 0
          end

          if options[:encrypt_method]
            Hiera::Backend::Eyaml.default_encryption_scheme = options[:encrypt_method]
          end

          options

        end

        def self.validate
          true
        end

        def self.description
          "no description"
        end

        def self.execute
          raise StandardError, "This command is not implemented yet (#{self.to_s.split('::').last})"
        end

        def self.hidden?
          false
        end

      end

    end
  end
end
