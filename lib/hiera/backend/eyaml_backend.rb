require 'hiera/backend/eyaml/encryptor'
require 'hiera/backend/eyaml/actions/decrypt_action'
require 'hiera/backend/eyaml/utils'
require 'hiera/backend/eyaml/parser/parser'
require 'yaml'

class Hiera
  module Backend
    class Eyaml_backend

      def initialize
        @extension = Config[:eyaml][:extension] ? Config[:eyaml][:extension] : "eyaml"

        debug("Hiera EYAML backend starting, with extension #{@extension}")
      end

      def lookup(key, scope, order_override, resolution_type)

        debug("Lookup called for key #{key}")
        answer = nil

        Backend.datasources(scope, order_override) do |source|
          eyaml_file = Backend.datafile(:eyaml, scope, source, @extension) || next

          debug("Processing datasource: #{eyaml_file}")

          if not @cache.nil?
            data = @cache.read(eyaml_file, Hash, {}) do |data|
              YAML.load(data)
            end
          else
            data = YAML.load_file(eyaml_file)
            unless data.is_a?(Hash)
              debug("YAML wasn't a hash, #{data} so defaulting to Hash {}")
              data = {}
            end
          end

          next if data.nil? or data.empty?
          debug ("Data contains valid YAML")

          next unless data.include?(key)
          debug ("Key #{key} found in YAML document")

          parsed_answer = parse_answer(key, data[key], scope)

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
              answer = Backend.merge_answer(parsed_answer,answer)
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

      def parse_answer(key, data, scope, extra_data={})
        if data.is_a?(Numeric) or data.is_a?(TrueClass) or data.is_a?(FalseClass)
          # Can't be encrypted
          data
        elsif data.is_a?(String)
          parsed_string = Backend.parse_string(data, scope)
          decrypt(key, parsed_string, scope)
        elsif data.is_a?(Hash)
          answer = {}
          data.each_pair do |key, val|
            answer[key] = parse_answer(key, val, scope, extra_data)
          end
          answer
        elsif data.is_a?(Array)
          answer = []
          data.each do |item|
            answer << parse_answer(key, item, scope, extra_data)
          end
          answer
        end
      end

      def deblock block_string
        block_string.gsub(/[ \n]/, '')
      end

      def decrypt(key, value, scope)

        if encrypted? value

          debug "Attempting to decrypt: #{key}"

          Config[:eyaml].each do |config_key, config_value|
            config_value = Backend.parse_string(Config[:eyaml][config_key], scope)
            debug "Setting: #{config_key} = #{config_value}"
            Eyaml::Options[config_key] = config_value
          end

          Eyaml::Options[:source] = "hiera"

          parser = Eyaml::Parser::ParserFactory.hiera_backend_parser
          tokens = parser.parse(value)
          decrypted = tokens.map{ |token| token.to_plain_text }
          plaintext = decrypted.join

          plaintext.chomp

        else
          value
        end
      end

      def encrypted?(value)
        if value.match(/.*ENC\[.*?\]/) then true else false end
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
