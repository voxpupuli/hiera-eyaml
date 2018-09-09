require 'base64'
require 'yaml'
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
           {:name          => :trace,
              :description => "Enable trace debug",
              :short       => 't'},
           {:name          => :quiet,
              :description => "Be less verbose",
              :short       => 'q'},
           {:name          => :help,
              :description => "Information on how to use this command",
              :short       => 'h'}
          ]
        
        def self.load_config_file
          config = { :options => {}, :sources => [] }
          [ "/etc/eyaml/config.yaml", "#{ENV['HOME']}/.eyaml/config.yaml", "#{ENV['EYAML_CONFIG']}" ].each do |config_file|
            begin
              yaml_contents = YAML.load_file(config_file)
              config[:options].merge! yaml_contents
              config[:sources].push(config_file)
            rescue 
              raise StandardError, "Could not open config file \"#{config_file}\" for reading"
            end if config_file and File.file? config_file
          end
          config
        end

        def self.all_options 
          options = @@global_options.dup
          options += self.options if self.options
          options += Plugins.options
          # merge in defaults from configuration files
          config_file = self.load_config_file
          options.map!{ | opt| 
            key_name = "#{opt[:name]}"
            if config_file[:options].has_key? key_name
              opt[:default] = config_file[:options][key_name]
              opt
            else
              opt
            end
          }
          { :options => options, :sources => config_file[:sources] || [] }
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

          me = self
          all = self.all_options

          options = Optimist::options do

            version "Hiera-eyaml version " + Hiera::Backend::Eyaml::VERSION.to_s
            banner ["eyaml #{me.prettyname}: #{me.description}", me.helptext, "Options:"].compact.join("\n\n")

            all[:options].each do |available_option|

              skeleton = {:description => "",
                          :short => :none}

              skeleton.merge! available_option
              opt skeleton[:name], 
                  skeleton[:desc] || skeleton[:description],  #legacy plugins 
                  :short => skeleton[:short], 
                  :default => skeleton[:default], 
                  :type => skeleton[:type]

            end

            stop_on Eyaml.subcommands

          end

          if options[:verbose]
            Hiera::Backend::Eyaml.verbosity_level += 1
          end

          if options[:trace]
            Hiera::Backend::Eyaml.verbosity_level += 2
          end

          if options[:quiet]
            Hiera::Backend::Eyaml.verbosity_level = 0
          end

          if options[:encrypt_method]
            Hiera::Backend::Eyaml.default_encryption_scheme = options[:encrypt_method]
          end

          if all[:sources]
            all[:sources].each do |source|
              LoggingHelper::debug "Loaded config from #{source}"
            end
          end

          options

        end

        def self.validate args
          args
        end

        def self.description
          "no description"
        end

        def self.helptext
          "Usage: eyaml #{self.prettyname} [options]"
        end

        def self.execute
          raise StandardError, "This command is not implemented yet (#{self.to_s.split('::').last})"
        end

        def self.prettyname
          Utils.snakecase self.to_s.split('::').last
        end

        def self.hidden?
          false
        end

      end

    end
  end
end
