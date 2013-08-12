require 'base64'

class Hiera
  module Backend
    module Eyaml

      class Encryptor

        attr_accessor :options

        def self.find encryption_scheme
          require "hiera/backend/eyaml/encryptors/#{encryptor_name}"          
          encryptor_module = Module.const_get('Hiera').const_get('Backend').const_get('Eyaml').const_get('Encryptors')
          encryptor_class = self.find_closest_class encryptor_module, encryptor_name
          raise StandardError, "Could not find hiera-eyaml encryptor: #{encryptor_name}. Try gem install hiera-eyaml-#{encryptor_name} ?" if encryptor_class.nil?
          encryptor_class
        end

        def self.encode binary_string
          Base64.encode64(binary_string).strip  
        end

        def self.decode string
          Base64.decode64(string)
        end

        def self.encrypt_string 
          raise StandardError "encrypt_string not defined for encryptor plugin: #{self.class.name}"
        end

        def self.decrypt_string
          raise StandardError "decrypt_string not defined for decryptor plugin: #{self.class.name}"
        end

        def self.encryptor_options
          @@encryptor_options
        end

        def self.encryptor_tag
          @@encryptor_tag
        end

        protected

          def self.find_closest_class parent_class, classname
            constants = parent_class.constants
            candidates = []
            constants.each do | candidate |
              candidates << candidate.to_s if candidate.to_s.downcase == classname.downcase
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

