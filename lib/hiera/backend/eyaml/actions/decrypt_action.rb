require 'hiera/backend/eyaml/utils'
require 'hiera/backend/eyaml/options'

class Hiera
  module Backend
    module Eyaml
      module Actions

        class DecryptAction

          REGEX_ENCRYPTED_BLOCK = />\n(\s*)ENC\[(\w+,)?([a-zA-Z0-9\+\/ =\n]+)\]/
          REGEX_ENCRYPTED_STRING = /ENC\[(\w+,)?([a-zA-Z0-9\+\/=]+)\]/

          def self.execute 

            output_data = case Eyaml::Options[:source]
            when :eyaml
              encryptions = []

              # blocks
              output = Eyaml::Options[:input_data].gsub( REGEX_ENCRYPTED_BLOCK ) { |match|
                indentation = $1
                encryption_scheme = parse_encryption_scheme( $2 )
                decryptor = Encryptor.find encryption_scheme
                ciphertext = $3.gsub(/[ \n]/, '')
                plaintext = decryptor.decrypt( decryptor.decode ciphertext )
                ">\n" + indentation + "DEC::#{decryptor.encryptor_tag}[" + plaintext + "]!"
              }

              # strings
              output.gsub!( REGEX_ENCRYPTED_STRING ) { |match|
                encryption_scheme = parse_encryption_scheme( $1 )
                decryptor = Encryptor.find encryption_scheme

                plaintext = decryptor.decrypt( decryptor.decode $2 )
                "DEC::#{decryptor.encryptor_tag}[" + plaintext + "]!"
              }

              output
            else

              output = Eyaml::Options[:input_data].gsub( REGEX_ENCRYPTED_STRING ) { |match|
                encryption_scheme = parse_encryption_scheme( $1 )
                decryptor = Encryptor.find encryption_scheme
                puts "DECRYPTOR.CLASSNAME = #{decryptor.class.name}, METHODS = #{decryptor.class.methods}"
                decryptor.decrypt( decryptor.decode $2 )
              } 

              output
            end

            output_data

          end

          protected

            def self.parse_encryption_scheme regex_result
              regex_result = Eyaml.default_encryption_scheme + "," if regex_result.nil?
              regex_result.split(",").first
            end

        end

      end
    end
  end
end
