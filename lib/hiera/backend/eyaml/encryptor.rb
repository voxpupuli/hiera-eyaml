require 'base64'
require 'hiera/backend/eyaml/encrypthelper'

class Hiera
  module Backend
    module Eyaml

      class Encryptor

        class << self
          attr_accessor :options
          attr_accessor :tag
        end

        def self.find encryption_scheme = nil
          encryption_scheme = Eyaml.default_encryption_scheme if encryption_scheme.nil?
          require "hiera/backend/eyaml/encryptors/#{File.basename encryption_scheme.downcase}"          
          encryptor_module = Module.const_get('Hiera').const_get('Backend').const_get('Eyaml').const_get('Encryptors')
          encryptor_class = Utils.find_closest_class :parent_class => encryptor_module, :class_name => encryption_scheme
          raise StandardError, "Could not find hiera-eyaml encryptor: #{encryption_scheme}. Try gem install hiera-eyaml-#{encryption_scheme.downcase} ?" if encryptor_class.nil?
          encryptor_class
        end

        def self.encode binary_string
          Base64.encode64(binary_string).strip  
        end

        def self.decode string
          Base64.decode64(string)
        end

        def self.encrypt *args 
          raise StandardError, "encrypt() not defined for encryptor plugin: #{self}"
        end

        def self.decrypt *args
          raise StandardError, "decrypt() not defined for decryptor plugin: #{self}"
        end

        protected

          def self.plugin_classname
            self.to_s.split("::").last.downcase
          end

          def self.register
            Hiera::Backend::Eyaml::Plugins.register_options :options => self.options, :plugin => plugin_classname
          end

          def self.option name
            Eyaml::Options[ "#{plugin_classname}_#{name}" ] || self.options[ "#{plugin_classname}_#{name}" ]
          end

          def self.hiera?
            Utils::hiera?
          end

          def self.format_message msg
            "[eyaml_#{plugin_classname}]:  #{msg}"
          end

          def self.trace msg
            LoggingHelper::trace :from => plugin_classname, :msg => msg
          end

          def self.debug msg
            LoggingHelper::debug :from => plugin_classname, :msg => msg
          end

          def self.info msg
            LoggingHelper::info :from => plugin_classname, :msg => msg
          end

          def self.warn msg
            LoggingHelper::warn :from => plugin_classname, :msg => msg
          end

      end

    end
  end
end

