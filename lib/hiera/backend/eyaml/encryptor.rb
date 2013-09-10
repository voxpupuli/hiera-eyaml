require 'base64'

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
          require "hiera/backend/eyaml/encryptors/#{encryption_scheme.downcase}"          
          encryptor_module = Module.const_get('Hiera').const_get('Backend').const_get('Eyaml').const_get('Encryptors')
          encryptor_class = self.find_closest_class :parent_class => encryptor_module, :class_name => encryption_scheme
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

          def self.find_closest_class args
            parent_class = args[ :parent_class ]
            class_name = args[ :class_name ]
            constants = parent_class.constants
            candidates = []
            constants.each do | candidate |
              candidates << candidate.to_s if candidate.to_s.downcase == class_name.downcase
            end
            if candidates.count > 0
              parent_class.const_get candidates.first
            else
              nil
            end
          end

          def self.hiera?
            "hiera".eql? Eyaml::Options[:source]
          end

          def self.format_message msg
            "[eyaml_#{plugin_classname}]:  #{msg}"
          end

          def self.debug msg
            if self.hiera?
              Hiera.debug format_message msg
            else
              STDERR.puts format_message msg
            end
          end

          def self.warn msg
            if self.hiera?
              Hiera.warn format_message msg
            else
              STDERR.puts format_message msg
            end
          end

      end

    end
  end
end

