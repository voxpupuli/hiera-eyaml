class Hiera
  module Backend
    module Eyaml

      class Encryptor

        attr_accessor :options

        def initialize args
          @input_data = args[:data]
          @options = args[:options]
        end

        def encrypt

          regex_decrypted_block = />\n(\s*)DEC(::#{self.class::ENCRYPT_TAG})\[(.+)\]\!/
          regex_decrypted_string = /DEC(::#{self.class::ENCRYPT_TAG})\[(.+)\]\!/
          if self.class.name.split('::').last.upcase == Utils.default_encryption
            regex_decrypted_block = />\n(\s*)DEC(::#{self.class::ENCRYPT_TAG})?\[(.+)\]\!/
            regex_decrypted_string = /DEC(::#{self.class::ENCRYPT_TAG})?\[(.+)\]\!/
          end

          case @options[:source]
          when :eyaml

            # blocks
            output = @input_data.gsub( regex_decrypted_block ) { |match|
              indentation = $1
              encryption_method = $2
              ciphertext = encrypt_string($3).gsub(/\n/, "\n" + indentation)
              ">\n" + indentation + "ENC[#{self.class::ENCRYPT_TAG},#{ciphertext}]"
            }

            # strings
            output.gsub( regex_decrypted_string ) { |match|
              encryption_method = $1
              ciphertext = encrypt_string($2).gsub(/\n/, "")
              "ENC[#{self.class::ENCRYPT_TAG},#{ciphertext}]"
            }

          else
            "ENC[#{self.class::ENCRYPT_TAG}," + encrypt_string( @input_data ) + "]"
          end
        end

        def decrypt

          regex_encrypted_block = />\n(\s*)ENC\[(#{self.class::ENCRYPT_TAG},)([a-zA-Z0-9\+\/ =\n]+)\]/
          regex_encrypted_string = /ENC\[(#{self.class::ENCRYPT_TAG},)([a-zA-Z0-9\+\/=]+)\]/
          if self.class.name.split('::').last.upcase == Utils.default_encryption
            regex_encrypted_block = />\n(\s*)ENC\[(#{self.class::ENCRYPT_TAG},)?([a-zA-Z0-9\+\/ =\n]+)\]/
            regex_encrypted_string = /ENC\[(#{self.class::ENCRYPT_TAG},)?([a-zA-Z0-9\+\/=]+)\]/
          end

          case @options[:source]
          when :eyaml

            # blocks
            output = @input_data.gsub( regex_encrypted_block ) { |match|
              indentation = $1
              encryption_method = if $2.nil? then Utils.default_encryption else $2.split(',').first end
              ciphertext = $3.gsub(/[ \n]/, '')
              plaintext = decrypt_string(ciphertext)
              ">\n" + indentation + "DEC::#{self.class::ENCRYPT_TAG}[" + plaintext + "]!"
            }

            # strings
            output.gsub!( regex_encrypted_string ) { |match|
              encryption_method = if $1.nil? then Utils.default_encryption else $1.split(',').first end
              plaintext = decrypt_string($2)
              "DEC::#{self.class::ENCRYPT_TAG}[" + plaintext + "]!"
            }

            output
          else

            output = @input_data.gsub( regex_encrypted_string ) { |match|
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

