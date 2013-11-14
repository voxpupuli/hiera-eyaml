require 'hiera/backend/eyaml/utils'
require 'hiera/backend/eyaml/actions/decrypt_action'
require 'hiera/backend/eyaml/actions/encrypt_action'
require 'hiera/backend/eyaml/options'
require 'hiera/backend/eyaml/parser/parser'

class Hiera
  module Backend
    module Eyaml
      module Actions

        class RecryptAction

          def self.execute

            encrypted_parser = Parser::ParserFactory.encrypted_parser
            tokens = encrypted_parser.parse Eyaml::Options[:input_data]
            decrypted_input = tokens.each_with_index.to_a.map{|(t,index)| t.to_decrypted :index => index}.join
            decrypted_file = Utils.write_tempfile decrypted_input

            edited_file = File.read decrypted_file
            Utils.secure_file_delete :file => decrypted_file, :num_bytes => [edited_file.length, decrypted_input.length].max

            raise StandardError, "Edited file is blank" if edited_file.empty?

            decrypted_parser = Parser::ParserFactory.decrypted_parser
            edited_tokens = decrypted_parser.parse(edited_file)

            encrypted_output = edited_tokens.map{ |t| t.to_encrypted }.join

            filename = Eyaml::Options[:eyaml]
            File.open("#{filename}", 'w') { |file|
              file.write encrypted_output
            }

            nil
          end

        end

      end
    end
  end
end
