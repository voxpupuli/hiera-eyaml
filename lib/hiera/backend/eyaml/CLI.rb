require 'trollop'
require 'hiera/backend/version'
require 'hiera/backend/eyaml/utils'
require 'hiera/backend/eyaml/actions/createkeys_action'
require 'hiera/backend/eyaml/actions/decrypt_action'
require 'hiera/backend/eyaml/actions/encrypt_action'
require 'hiera/backend/eyaml/actions/edit_action'

module Hiera
  module Backend
    module Eyaml
      class CLI

        DEFAULT_ENCRYPTION = "pkcs7"

        def self.parse

          options = Trollop::options do
              
            version "Hiera-eyaml version " + Hiera::Backend::Eyaml::VERSION.to_s
            banner <<-EOS
Hiera-eyaml is a backend for Hiera which provides OpenSSL encryption/decryption for Hiera properties

Usage:
  eyaml [options] [string-to-encrypt]
  EOS
          
            opt :createkeys, "Create public and private keys for use encrypting properties", :short => 'c'
            opt :decrypt, "Decrypt something"
            opt :encrypt, "Encrypt something"
            opt :edit, "Decrypt, Edit, and Reencrypt"
            opt :eyaml, "Source input is an eyaml file", :type => :string
            opt :password, "Source input is a password entered on the terminal", :short => 'p'
            opt :string, "Source input is a string provided as an argument", :short => 's', :type => :string
            opt :file, "Source input is a file", :short => 'f', :type => :string
            opt :private_key_dir, "Directory containing private_keys", :type => :string, :default => "./keys"
            opt :public_key_dir, "Directory containing public keys", :type => :string, :default => "./keys"
            opt :encrypt_method, "Encryption method (only if encrypting a password, string or regular file)", :default => "pkcs7"
            opt :output, "Output format of final result (examples, block, string)", :type => :string, :default => "examples"
          end

          actions = [:createkeys, :decrypt, :encrypt, :edit].collect {|x| x if options[x]}.compact
          sources = [:eyaml, :password, :string, :file].collect {|x| x if options[x]}.compact

          Trollop::die "You can only specify one of (#{actions.join(', ')})" if actions.count > 1
          Trollop::die "You can only specify one of (#{sources.join(', ')})" if sources.count > 1
          Trollop::die "Creating keys does not require a source to encrypt/decrypt" if actions.first == :createkeys and sources.count > 0

          source = sources.first
          action = actions.first

          options[:input_data] = case source
          when :password
            Utils.read_password
          when :string
            options[:string]
          when :file
            File.read options[:file]
          when :eyaml
            File.read options[:eyaml]
          else
            nil
          end

          encryptions = {}

          if [:password, :string, :file].include? source and action == :encrypt
            encryptions[ options[:encrypt_method] ] = nil
          elsif action == :createkeys
            encryptions[ options[:encrypt_method] ] = nil
          else
            options[:input_data].gsub( /ENC\[([^\]]+,)?([^\]]*)\]/ ) { |match|
              encryption_method = $1
              encryption_method = DEFAULT_ENCRYPTION if encryption_method.nil?
              encryptions[ encryption_method ] = nil
            }
          end

          encryptions.keys.each do |encryption_method|
            encryptor = nil
            encryptor_class = nil
            begin
              require "hiera/backend/eyaml/encryptors/#{encryption_method}"
            rescue LoadError
              raise StandardError, "Encryption method #{encryption_method} not available. Have you tried gem install hiera-eyaml-#{encryption_method} ?"
            end
            encryptions[ encryption_method ] = Utils.find_encryptor encryption_method
          end

          options[:encryptions] = encryptions

          { :action => action, :options => options }

        end

        def self.execute args

          action = args[:action]

          action_class = Module.const_get('Hiera').const_get('Backend').const_get('Eyaml').const_get('Actions').const_get("#{Utils.camelcase action.to_s}Action")
          puts action_class.execute args[:options]

        end          

      end

    end

  end

end
