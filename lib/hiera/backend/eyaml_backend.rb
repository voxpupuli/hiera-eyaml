require 'hiera/backend/eyaml/encryptor'
require 'hiera/backend/eyaml/actions/decrypt_action'
require 'hiera/backend/eyaml/utils'
require 'yaml'

class Hiera
  module Backend
    class Eyaml_backend
      
      def initialize
      end

      def lookup(key, scope, order_override, resolution_type)

        debug("Lookup called for key #{key}")
        answer = nil

        Backend.datasources(scope, order_override) do |source|
          eyaml_file = Backend.datafile(:eyaml, scope, source, "eyaml") || next

          debug("Processing datasource: #{eyaml_file}")

          data = YAML.load(File.read( eyaml_file ))

          next if data.nil? or data.empty?
          debug ("Data contains valid YAML")

          next unless data.include?(key)
          debug ("Key #{key} found in YAML document")

          parsed_answer = parse_answer(data[key], scope)

          begin
            case resolution_type
            when :array
              debug("Appending answer array")
              raise Exception, "Hiera type mismatch: expected Array and got #{parsed_answer.class}" unless parsed_answer.kind_of? Array or parsed_answer.kind_of? String
              answer ||= []
              answer << parsed_answer
            when :hash
              debug("Merging answer hash")
              raise Exception, "Hiera type mismatch: expected Hash and got #{parsed_answer.class}" unless parsed_answer.kind_of? Hash
              answer ||= {}
              answer = parsed_answer.merge answer
            else
              debug("Assigning answer variable")
              answer = parsed_answer
              break
            end
          rescue NoMethodError
            raise Exception, "Resolution type is #{resolution_type} but parsed_answer is a #{parsed_answer.class}"
          end
        end

        answer
      end

      def parse_answer(data, scope, extra_data={})
        if data.is_a?(Numeric) or data.is_a?(TrueClass) or data.is_a?(FalseClass)
          # Can't be encrypted
          data
        elsif data.is_a?(String)
          parsed_string = Backend.parse_string(data, scope)
          decrypt(parsed_string, scope)
        elsif data.is_a?(Hash)
          answer = {}
          data.each_pair do |key, val|
            answer[key] = parse_answer(val, scope, extra_data)
          end
          answer
        elsif data.is_a?(Array)
          answer = []
          data.each do |item|
            answer << parse_answer(item, scope, extra_data)
          end
          answer
        end
      end

      def decrypt(value, scope)

        # debug "Attempting to decrypt: #{value}"
        if encrypted? value

          private_key_dir = Backend.parse_string(Config[:eyaml][:private_key_dir], scope) || '/etc/hiera/keys'
          public_key_dir = Backend.parse_string(Config[:eyaml][:public_key_dir], scope) || '/etc/hiera/keys'


          plaintext = value.gsub( /ENC\[([^\]]*)\]/ ) { |match|
            encrypted_value = match.to_s
            encrypted_info = $1.gsub(/[ \n]/, '').split(',')
            encrypted_info.unshift Hiera::Backend::Eyaml::Utils.default_encryption if encrypted_info.length == 1

            encryption_method = encrypted_info.first.downcase

            encryptor_class = nil
            begin
              require "hiera/backend/eyaml/encryptors/#{encryption_method}"
              cipher_class = Hiera::Backend::Eyaml::Utils.camelcase( encryption_method )
              encryptor_class = Module.const_get('Hiera').const_get('Backend').const_get('Eyaml').const_get('Encryptors').const_get(cipher_class)
            rescue
              raise StandardError, "Encryption method #{encryption_method} not available. Try gem install hiera-eyaml-#{cipherscheme} ?"
            end

            options = {:input_data => encrypted_value, 
                       :encryptions => { encryption_method => encryptor_class }, 
                       :private_key_dir => private_key_dir, 
                       :public_key_dir => public_key_dir,
                       :output => "raw" }

            debug("Decrypting value: #{encrypted_value}, using method: #{encryption_method}")
            begin
              plaintext_part = Hiera::Backend::Eyaml::Actions::DecryptAction.execute options
            rescue
              raise Exception, "Hiera eyaml backend: Unable to decrypt hiera data. Do the keys match and are they the same as those used to encrypt?"
            end

            # debug "plaintext: #{plaintext_part}"

            plaintext_part
          }

          plaintext

        else
          debug "value was not encrypted"
          value
        end
      end

      def encrypted?(value)
        if value.match(/.*ENC\[.*?\]/)
          true
        else
          false
        end
      end

      def debug(msg)
        Hiera.debug("[eyaml_backend]: #{msg}")
      end

      def warn(msg)
        Hiera.warn("[eyaml_backend]:  #{msg}")
      end
    end
  end
end
