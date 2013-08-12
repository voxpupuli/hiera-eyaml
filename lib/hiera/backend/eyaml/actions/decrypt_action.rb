require 'hiera/backend/eyaml/utils'

class Hiera
  module Backend
    module Eyaml
      module Actions

        class DecryptAction

          REGEX_ENCRYPTED_BLOCK = />\n(\s*)ENC\[(#{self.encryptor_tag},)?([a-zA-Z0-9\+\/ =\n]+)\]/
          REGEX_ENCRYPTED_STRING = /ENC\[(#{self.encryptor_tag},)?([a-zA-Z0-9\+\/=]+)\]/

          def self.execute options

            output_data = case options[:source]
            when :eyaml
              encryptions = []

              # blocks
              output = options[:input_data].gsub( regex_encrypted_block ) { |match|
                indentation = $1
                encryption_scheme = parse_encryption_scheme( $2 )
                decryptor = Encryptor.find encryption_scheme
                ciphertext = $3.gsub(/[ \n]/, '')
                plaintext = decryptor.decrypt( self.decode ciphertext )
                ">\n" + indentation + "DEC::#{self.encryptor_tag}[" + plaintext + "]!"
              }

              # strings
              output.gsub!( regex_encrypted_string ) { |match|
                encryption_scheme = parse_encryption_scheme( $1 )
                decryptor = Encryptor.find encryption_scheme

                plaintext = self.decrypt( self.decode $2 )
                "DEC::#{self.encryptor_tag}[" + plaintext + "]!"
              }

              output
            else

              output = options[:input_data].gsub( regex_encrypted_string ) { |match|
                encryption_scheme = parse_encryption_scheme( $1 )
                decryptor = Encryptor.find encryption_scheme
                decryptor.decrypt( decode $2 )
              } 

              output
            end

            output_data

          end

          protected

            def self.parse_encryption_scheme regex_result
              regex_result = Utils.default_encryption + "," if regex_result.nil?
              regex_result.split(",").first
            end

        end

      end
    end
  end
end
