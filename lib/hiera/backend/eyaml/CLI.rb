require 'trollop'
require 'hiera/backend/eyaml'
require 'hiera/backend/eyaml/utils'
require 'hiera/backend/eyaml/actions/createkeys_action'
require 'hiera/backend/eyaml/actions/decrypt_action'
require 'hiera/backend/eyaml/actions/encrypt_action'
require 'hiera/backend/eyaml/actions/recrypt_action'
require 'hiera/backend/eyaml/actions/edit_action'
require 'hiera/backend/eyaml/plugins'
require 'hiera/backend/eyaml/options'

class Hiera
  module Backend
    module Eyaml
      class CLI

        def self.parse

          options = Trollop::options do

            version "Hiera-eyaml version " + Hiera::Backend::Eyaml::VERSION.to_s
            banner <<-EOS
Hiera-eyaml is a backend for Hiera which provides OpenSSL encryption/decryption for Hiera properties

Usage:
  eyaml [options]
  eyaml -i file.eyaml       # edit a file
  eyaml -e -s some-string   # encrypt a string
  eyaml -e -p               # encrypt a password
  eyaml -e -f file.txt      # encrypt a file
  cat file.txt | eyaml -e   # encrypt a file on a pipe

Options:
  EOS

            opt :createkeys, "Create public and private keys for use encrypting properties", :short => 'c'
            opt :decrypt, "Decrypt something", :short => 'd'
            opt :encrypt, "Encrypt something", :short => 'e'
            opt :recrypt, "Recrypt something", :short => 'r', :type => :string
            opt :edit, "Decrypt, Edit, and Reencrypt", :short => 'i', :type => :string
            opt :eyaml, "Source input is an eyaml file", :short => 'y', :type => :string
            opt :password, "Source input is a password entered on the terminal", :short => 'p'
            opt :string, "Source input is a string provided as an argument", :short => 's', :type => :string
            opt :file, "Source input is a file", :short => 'f', :type => :string
            opt :stdin, "Source input is taken from stdin", :short => :none
            opt :encrypt_method, "Override default encryption and decryption method (default is PKCS7)", :short => 'n', :default => "pkcs7"
            opt :output, "Output format of final result (examples, block, string)", :type => :string, :short => 'o', :default => "examples"
            opt :label, "Apply a label to the encrypted result", :short => 'l', :type => :string
            opt :debug, "Be more verbose", :short => :none
            opt :quiet, "Be less verbose", :short => :none

            Hiera::Backend::Eyaml::Plugins.options.each do |name, option|
              opt name, option[:desc], :type => option[:type], :short => option[:short], :default => option[:default]
            end

          end

          actions = [:createkeys, :decrypt, :recrypt, :encrypt, :edit].collect {|x| x if options[x]}.compact
          sources = [:edit, :recrypt, :eyaml, :password, :string, :file, :stdin].collect {|x| x if options[x]}.compact
          # sources << :stdin if STDIN

          Trollop::die "You can only specify one of (#{actions.join(', ')})" if actions.count > 1
          Trollop::die "You can only specify one of (#{sources.join(', ')})" if sources.count > 1
          Trollop::die "Creating keys does not require a source to encrypt/decrypt" if actions.first == :createkeys and sources.count > 0

          options[:source] = sources.first
          options[:action] = actions.first
          options[:source] = :not_applicable if options[:action] == :createkeys

          Trollop::die "Nothing to do" if options[:source].nil? or options[:action].nil?

          options[:input_data] = case options[:source]
          when :stdin
            STDIN.read
          when :password
            Utils.read_password
          when :string
            options[:string]
          when :file
            File.read options[:file]
          when :eyaml
            File.read options[:eyaml]
          when :stdin
            STDIN.read
          else
            if options[:edit]
              options[:eyaml] = options[:edit]
              options[:source] = :eyaml
              File.read options[:edit]
            elsif options[:recrypt]
              options[:eyaml] = options[:recrypt]
              options[:source] = :eyaml
              File.read options[:recrypt]
            else
              nil
            end
          end

          Eyaml.default_encryption_scheme = options[:encrypt_method].upcase if options[:encrypt_method]
          Eyaml::Options.set options
          Eyaml::Options.debug

        end

        def self.execute

          action = Eyaml::Options[:action]
          action_class = Module.const_get('Hiera').const_get('Backend').const_get('Eyaml').const_get('Actions').const_get("#{Utils.camelcase action.to_s}Action")

          return_value = action_class.execute
          puts return_value unless return_value.nil?

        end

      end

    end

  end

end
