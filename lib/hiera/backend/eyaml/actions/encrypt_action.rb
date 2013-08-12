require 'hiera/backend/eyaml/options'

class Hiera
  module Backend
    module Eyaml
      module Actions

        class EncryptAction

          REGEX_DECRYPTED_BLOCK = />\n(\s*)DEC(::\w+)?\[(.+)\]\!/
          REGEX_DECRYPTED_STRING = /DEC(::\w+)?\[(.+)\]\!/

          def self.execute 

            output_data = case Eyaml::Options[:source]
            when :eyaml
              encryptions = []

              # blocks
              output = Eyaml::Options[:input_data].gsub( REGEX_DECRYPTED_BLOCK ) { |match|
                indentation = $1
                encryption_scheme = parse_encryption_scheme( $2 )
                encryptor = Encryptor.find encryption_scheme
                ciphertext = encryptor.encode( encryptor.encrypt($3) ).gsub(/\n/, "\n" + indentation)
                ">\n" + indentation + "ENC[#{encryptor.tag},#{ciphertext}]"
              }

              # strings
              output.gsub!( REGEX_DECRYPTED_STRING ) { |match|
                encryption_scheme = parse_encryption_scheme( $1 )
                encryptor = Encryptor.find encryption_scheme
                ciphertext = encryptor.encode( encryptor.encrypt($2) ).gsub(/\n/, "")
                "ENC[#{encryptor.tag},#{ciphertext}]"
              }

            else
              encryptor = Encryptor.find
              ciphertext = encryptor.encode( encryptor.encrypt(Eyaml::Options[:input_data]) )
              "ENC[#{encryptor.tag},#{ciphertext}]"
            end

            self.format :data => output_data, :structure => Eyaml::Options[:output]

          end

          protected

            def self.parse_encryption_scheme regex_result
              regex_result = "::" + Eyaml.default_encryption_scheme if regex_result.nil?
              regex_result.split("::").last
            end

            def self.format args
              data = args[:data]
              data_as_block = data.split("\n").join("\n    ")
              data_as_string = data.split("\n").join("")
              structure = args[:structure]

              case structure
              when "examples"
                "string: #{data_as_string}\n\n" +
                "OR\n\n" +
                "block: >\n" +
                "    #{data_as_block}" 
              when "block"
                "    #{data_as_block}" 
              when "string"
                "#{data_as_string}"
              else
                data.to_s
              end

            end

        end

      end
    end
  end
end
