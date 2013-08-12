class Hiera
  module Backend
    module Eyaml
      module Actions

        class EncryptAction

          REGEX_DECRYPTED_BLOCK = />\n(\s*)DEC(::#{self.encryptor_tag})?\[(.+)\]\!/
          REGEX_DECRYPTED_STRING = /DEC(::#{self.encryptor_tag})?\[(.+)\]\!/

          def self.execute options

            output_data = case options[:source]
            when :eyaml
              encryptions = []

              # blocks
              output = option[:input_data].gsub( REGEX_DECRYPTED_BLOCK ) { |match|
                indentation = $1
                encryption_scheme = parse_encryption_scheme( $2 )
                encryptor = Encryptor.find encryption_scheme
                ciphertext = encode( encryptor.encrypt($3) ).gsub(/\n/, "\n" + indentation)
                ">\n" + indentation + "ENC[#{self.encryptor_tag},#{ciphertext}]"
              }

              # strings
              output.gsub!( REGEX_DECRYPTED_STRING ) { |match|
                encryption_scheme = parse_encryption_scheme( $1 )
                encryptor = Encryptor.find encryption_scheme
                ciphertext = encode( encryptor.encrypt($2) ).gsub(/\n/, "")
                "ENC[#{self.encryptor_tag},#{ciphertext}]"
              }

            else
              encryptor = Encryptor.find Utils.default_encryption
              ciphertext = encode( encryptor.encrypt(options[:input_data]) )
              "ENC[#{self.encryptor_tag},#{ciphertext}]"
            end

            self.format :data => output_data, :structure => options[:output]

          end

          protected

            def self.parse_encryption_scheme regex_result
              regex_result = "::" + Utils.default_encryption if regex_result.nil?
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
