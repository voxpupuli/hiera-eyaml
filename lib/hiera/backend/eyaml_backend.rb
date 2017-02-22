require 'hiera/backend/eyaml/encryptor'
require 'hiera/backend/eyaml/utils'
require 'hiera/backend/eyaml/options'
require 'hiera/backend/eyaml/parser/parser'
require 'hiera/filecache'
require 'hiera/version'

require 'yaml'

class Hiera
  module Backend
    class Eyaml_backend

      attr_reader :extension

      def initialize(cache = nil)
        debug("Hiera eYAML backend starting")

        @decrypted_cache   = {}
        @cache             = cache || Filecache.new
        @extension         = Config[:eyaml][:extension] || "eyaml"
        @hiera_api_version = Hiera.version.split('.')[0].to_i
      end

      def lookup(key, scope, order_override, resolution_type, context={:recurse_guard => nil, :order_override => nil})
        answer = nil

        parse_options(scope)

        debug("Looking up #{key} in eYAML backend")

        Backend.datasources(scope, order_override) do |source|
          debug("Looking for data source #{source}")
          eyaml_file = Backend.datafile(:eyaml, scope, source, extension) || next

          next unless File.exists?(eyaml_file)

          data = @cache.read(eyaml_file, Hash) do |data|
            YAML.load(data) || {}
          end

          next if data.empty?
          next unless data.include?(key)

          # Extra logging that we found the key. This can be outputted
          # multiple times if the resolution type is array or hash but that
          # should be expected as the logging will then tell the user ALL the
          # places where the key is found.
          debug("Found #{key} in #{source}")

          # for array resolution we just append to the array whatever
          # we find, we then goes onto the next file and keep adding to
          # the array
          #
          # for priority searches we break after the first found data item
          if @hiera_api_version > 1
            new_answer = parse_answer(data[key], scope, {}, context={:recurse_guard => nil, :order_override => nil})
          else
            new_answer = parse_answer(data[key], scope)
          end
          case resolution_type
          when :array
            raise Exception, "Hiera type mismatch: expected Array and got #{new_answer.class}" unless new_answer.kind_of? Array or new_answer.kind_of? String
            answer ||= []
            answer << new_answer
          when :hash
            raise Exception, "Hiera type mismatch: expected Hash and got #{new_answer.class}" unless new_answer.kind_of? Hash
            answer ||= {}
            answer = Backend.merge_answer(new_answer,answer)
          else
            answer = new_answer
            break
          end
        end

        return answer
      end

      private

      def debug(message)
        Hiera.debug("[eyaml_backend]: #{message}")
      end

      def decrypt(data)
        if encrypted?(data)
          debug("Attempting to decrypt")
          begin
            parser = Eyaml::Parser::ParserFactory.hiera_backend_parser
            tokens = parser.parse(data)
            decrypted = tokens.map{ |token| token.to_plain_text }
            plaintext = decrypted.join
          rescue OpenSSL::PKCS7::PKCS7Error => e
            debug("Caught exception: #{e.class}, #{e.message}\n"\
                  "#{e.backtrace.join("\n")}")
            raise "Hiera-eyaml decryption failed, check the "\
              "encrypted data matches the key you are using.\n"\
              "Raw message from system: #{e.message}"

          end
          plaintext.chomp
        else
          data
        end
      end

      def encrypted?(data)
        /.*ENC\[.*?\]/ =~ data ? true : false
      end

      def parse_answer(data, scope, extra_data={}, context={:recurse_guard => nil, :order_override => nil})
        if data.is_a?(Numeric) or data.is_a?(TrueClass) or data.is_a?(FalseClass)
          return data
        elsif data.is_a?(String)
          if @hiera_api_version > 1
            return parse_string(data, scope, extra_data, context)
          else
            return parse_string(data, scope, extra_data)
          end

        elsif data.is_a?(Hash)
          answer = {}
          data.each_pair do |key, val|
            if @hiera_api_version > 1
              debug("Using Hiera Backend API v2 to call Backend.parse_string with context")
              interpolated_key = Backend.parse_string(key, scope, extra_data, context)
              answer[interpolated_key] = parse_answer(val, scope, extra_data, context)
            else
              debug("Using Hiera Backend API v1 to call Backend.parse_string")
              interpolated_key = Backend.parse_string(key, scope, extra_data)
              answer[interpolated_key] = parse_answer(val, scope, extra_data)
            end
          end

          return answer
        elsif data.is_a?(Array)
          answer = []
          data.each do |item|
            if @hiera_api_version > 1
              answer << parse_answer(item, scope, extra_data, context)
            else
              answer << parse_answer(item, scope, extra_data)
            end
          end

          return answer
        end
      end

      def parse_options(scope)
        Config[:eyaml].each do |key, value|
          parsed_value = Backend.parse_string(value, scope)
          Eyaml::Options[key] = parsed_value
          debug("Set option: #{key} = #{parsed_value}")
        end

        Eyaml::Options[:source] = "hiera"
      end

      def parse_string(data, scope, extra_data={}, context={:recurse_guard => nil, :order_override => nil})
        if Eyaml::Options[:cache_decrypted]
          if not @decrypted_cache.include?(data)
            decrypted_data = decrypt(data)
            debug("Adding data to decrypted cache")
            @decrypted_cache[data] = decrypted_data
          else
            debug("Retrieving data from decrypted cache")
            decrypted_data = @decrypted_cache[data]
          end
        else
          decrypted_data = decrypt(data)
        end

        if @hiera_api_version > 1
          debug("Using Hiera Backend API v2 to call Backend.parse_string with context")
          Backend.parse_string(decrypted_data, scope, extra_data, context)
        else
          debug("Using Hiera Backend API v1 to call Backend.parse_string")
          Backend.parse_string(decrypted_data, scope, extra_data)
        end
      end
    end
  end
end
