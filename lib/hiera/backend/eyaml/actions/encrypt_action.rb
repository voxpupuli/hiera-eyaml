require 'hiera/backend/eyaml/options'

class Hiera
  module Backend
    module Eyaml
      module Actions

        class EncryptAction

          REGEX_DECRYPTED_BLOCK = />\n(\s*)DEC(::\w+)?\[(.+)\]\!/
          REGEX_DECRYPTED_STRING = /DEC(::\w+)?\[(.+)\]\!/

          def self.execute 

            case Eyaml::Options[:source]
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
              output.gsub( REGEX_DECRYPTED_STRING ) { |match|
                encryption_scheme = parse_encryption_scheme( $1 )
                encryptor = Encryptor.find encryption_scheme
                ciphertext = encryptor.encode( encryptor.encrypt($2) ).gsub(/\n/, "")
                "ENC[#{encryptor.tag},#{ciphertext}]"
              }

            else
              encryptor = Encryptor.find
              ciphertext = encryptor.encode( encryptor.encrypt(Eyaml::Options[:input_data]) )
              self.format :data => "ENC[#{encryptor.tag},#{ciphertext}]", :structure => Eyaml::Options[:output], :label => Eyaml::Options[:label]
            end

          end

          protected

            def self.parse_encryption_scheme regex_result
              regex_result = "::" + Eyaml.default_encryption_scheme if regex_result.nil?
              regex_result.split("::").last
            end

            def self.format_string data, label
              data_as_string = data.split("\n").join("")
              prefix = label ? "#{label}: " : ''
              prefix + data_as_string
            end

            def self.format_block data, label
              data_as_block = data.split("\n").join("\n    ")
              prefix = label ? "#{label}: >\n" : ''
              prefix + "    #{data_as_block}"
            end

            def self.format args
              data = args[:data]
              structure = args[:structure]
              label = args[:label]

              case structure
              when "examples"
                self.format_string(data, label || 'string') + "\n\n" +
                "OR\n\n" +
                self.format_block(data, label || 'block')
              when "block"
                self.format_block data, label
              when "string"
                self.format_string data, label
              else
                data.to_s
              end

            end

        end

      end
    end
  end
end
