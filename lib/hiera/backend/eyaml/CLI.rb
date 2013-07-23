require 'trollop'
require 'hiera/backend/version'
require 'hiera/backend/eyaml/utils'
require 'hiera/backend/eyaml/actions/createkeys'
require 'hiera/backend/eyaml/actions/decrypt'
require 'hiera/backend/eyaml/actions/encrypt'
require 'hiera/backend/eyaml/actions/edit'

module Hiera
  module Backend
    module Eyaml
      class CLI

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
            opt :eyaml, "Source input is an eyaml file", type => :string
            opt :password, "Source input is a password entered on the terminal", :short => 'p'
            opt :string, "Source input is a string provided as an argument", :short => 's', :type => :string
            opt :file, "Source input is a file", :short => 'f', :type => :string
            opt :private_key_dir, "Directory containing private_keys", :type => :string, :default => "/etc/hiera/keys"
            opt :public_key_dir, "Directory containing public keys", :type => :string, :default => "/etc/hiera/keys"
            opt :encrypt_method, "Encryption method (only if encrypting a password, string or regular file)", :default => "pkcs7"
            opt :output, "Output format of final result (examples, block, string)", :type => :string, :default => "examples"
          end

          actions = [:createkeys, :decrypt, :encrypt, :edit].collect {|x| x if options[x]}.compact
          sources = [:eyaml, :password, :string, :file].collect {|x| x if options[x]}.compact

          Trollop::die "You can only specify one of #{actions.join(',')}" if actions.count > 1
          Trollop::die "You can only specify one of #{sources.join(',')}" if sources.count > 1
          Trollop::die "Creating keys does not require a source to encrypt/decrypt" if actions.first = :createkeys and sources.count > 0

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

          if [:password, :string, :file].contains source and action == :encrypt
            encryptions[ options[:encrypt_method] ] = nil
          elsif action == :createkeys
            encryptions[ options[:encrypt_method] ] = nil
          else            
            options[:input_data].gsub( /ENC\!?\[([A-Za-z0-9_]*),/ ) { |match|
              encryptions[ $1 ] = nil
            }
          end

          encryptions.keys.each do |encryption_method|
            encryptor = nil
            encryptor_class = nil
            begin
              require "hiera/backend/eyaml/encryptors/#{options[:method]}"
              encryptor_class = module.const_get('hiera').const_get('backend').const_get('eyaml').const_get('encryptors').const_get(options[:method])
              encryptions[ encryption_method ] = encryptor_class
            rescue
              $stderr.puts "Encryption method #{options[:method]} not available. Have you tried gem install hiera-eyaml-#{options[:method]} ?"
            end
          end

          options[:encryptions] = encryptions

          { :action => action, :options => options }

        end

        def self.execute args

          action = args[:action]

          action_class = module.const_get('hiera').const_get('backend').const_get('eyaml').const_get('actions').const_get(action)
          puts action_class.execute args[:options]

        end          

      end

    end

  end

end
