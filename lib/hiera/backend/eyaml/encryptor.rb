module Hiera
  module Backend
    module Eyaml

      ENCRYPTED_BLOCK = />\n(\s*)ENC\[(${ENCRYPT_TAG},)?([a-zA-Z0-9+\/ \n]+)\]/
      ENCRYPTED_STRING = /ENC\[(${ENCRYPT_TAG},)?([a-zA-Z0-9+\/]+)\]/
      DECRYPTED_BLOCK = />\n(\s*)ENC!\[(${ENCRYPT_TAG},)?(.+)\]!ENC/
      DECRYPTED_STRING = /ENC!\[(${ENCRYPT_TAG},)?(.+)\]!ENC/

      class Encryptor

        attr_accessor :options

        def initialize args
          @input_data = args[:data]
          @options = args[:options]
        end

        def encrypt
          case @options[:data_type]
          when :eyaml_file

            # blocks
            output = input_data.gsub( DECRYPTED_BLOCK ) { |match|
              indentation = $1
              ciphertext = encrypt_string($2).gsub(/\n/, "\n" + indentation)
              ">\n" + indentation + "ENC[" + ciphertext + "]"
            }

            # strings
            output.gsub( DECRYPTED_STRING ) { |match|
              ciphertext = encrypt_string($1).gsub(/\n/, "")
              "ENC[" + ciphertext + "]"
            }

          else
            "ENC[" + encrypt_string( @input_data ) + "]"
          end
        end

        def decrypt
          case @options[:data_type]
          when :eyaml_file

            # blocks
            output = @input_data.gsub( ENCRYPTED_BLOCK ) { |match|
              indentation = $1
              ciphertext = $3.gsub(/[ \n]/, '')
              plaintext = decrypt_string(ciphertext)
              ">\n" + indentation + "ENC![#{ENCRYPT_TAG}," + plaintext + "]!ENC"
            }

            # strings
            output.gsub( ENCRYPTED_STRING ) { |match|
              plaintext = decrypt_string($2)
              "ENC![#{ENCRYPT_TAG}," + plaintext + "]!ENC"
            }

            output
          else

            output = @input_data.gsub( ENCRYPTED_STRING ) { |match|
              decrypt_string($2)
            } 

            output
          end
        end

        def encrypt_string 
          raise StandardError "encrypt_string not defined for encryptor plugin: #{self.class.name}"
        end

        def decrypt_string
          raise StandardError "decrypt_string not defined for decryptor plugin: #{self.class.name}"
        end

      end

    end
  end
end

