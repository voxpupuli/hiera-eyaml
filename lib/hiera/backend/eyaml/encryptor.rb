require 'base64'

class Hiera
  module Backend
    module Eyaml

      class Encryptor

        attr_accessor :options

        def self.find encryption_scheme
          require "hiera/backend/eyaml/encryptors/#{encryption_scheme}"          
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

        def self.encryptor_options
          @@encryptor_options
        end

        def self.encryptor_tag
          @@encryptor_tag
        end

        protected

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

      end

    end
  end
end

