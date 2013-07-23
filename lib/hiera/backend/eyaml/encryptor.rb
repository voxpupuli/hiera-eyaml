module Hiera
  module Backend
    module Eyaml

      ENCRYPTED_BLOCK = />\n( *)ENC\[(${ENCRYPT_TAG},)?([a-zA-Z0-9+\/ \n]+)\]/
      ENCRYPTED_STRING = /ENC\[(${ENCRYPT_TAG},)?[a-zA-Z0-9+\/]+)\]/
      DECRYPTED_BLOCK = />\n( *)ENC!\[(${ENCRYPT_TAG},)?(.+)\]!ENC/
      DECRYPTED_STRING = /ENC!\[(${ENCRYPT_TAG},)?(.+)\]!ENC/

      class Encryptor

        def initialize input_data, options
          @input_data = input_data
          @options = options
        end

        def encrypt
          case @options[:data_type]
          when :eyaml_file

            # blocks
            output = input_data.gsub( DECRYPTED_BLOCK ) { |match|
              indentation = $1
              ciphertext = encrypt($2).gsub(/\n/, "\n" + indentation)
              ">\n" + indentation + "ENC[" + ciphertext + "]"
            }

            # strings
            output.gsub( DECRYPTED_STRING ) { |match|
              ciphertext = encrypt($1).gsub(/\n/, "")
              "ENC[" + ciphertext + "]"
            }

          else
            "ENC[" + encrypt( input_data ) + "]"
          end
        end

        def decrypt
          case @options[:data_type]
          when :eyaml_file

            # blocks
            output = input_data.gsub( ENCRYPTED_BLOCK ) { |match|
              indentation = $1
              ciphertext = $2.gsub(/[ \n]/, '')
              plaintext = decrypt(ciphertext)
              ">\n" + indentation + "ENC![" + plaintext + "]!ENC"
            }

            # strings
            output.gsub( ENCRYPTED_STRING ) { |match|
              plaintext = decrypt($1)
              "ENC![" + plaintext + "]!ENC"
            }
          else
            decrypt input_data 
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

