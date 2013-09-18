require 'hiera/backend/eyaml/utils'
require 'hiera/backend/eyaml/actions/decrypt_action'
require 'hiera/backend/eyaml/actions/encrypt_action'
require 'hiera/backend/eyaml/options'
require 'hiera/backend/eyaml/parser/parser'

class Hiera
  module Backend
    module Eyaml
      module Actions
  
        class EditAction

          def self.execute 

            encrypted_parser = Parser::ParserFactory.encrypted_parser
            tokens = encrypted_parser.parse Eyaml::Options[:input_data]
            decrypted_input = tokens.each_with_index.to_a.map{|(t,index)| t.to_decrypted :index => index}.join
            decrypted_file = Utils.write_tempfile decrypted_input

            editor = Utils.find_editor
            system editor, decrypted_file
            status = $?
            raise StandardError, "Editor #{editor} has not exited?" unless status.exited?
            raise StandardError, "Editor did not exit successfully (exit code #{status.exitstatus}), aborting" unless status.exitstatus  #TODO: The file is left on the disk
            raise StandardError, "File was moved by editor" unless File.file? decrypted_file

            edited_file = File.read decrypted_file
            Utils.secure_file_delete :file => decrypted_file, :num_bytes => [edited_file.length, decrypted_input.length].max
            raise StandardError, "Edited file is blank" if edited_file.empty?
            raise StandardError, "No changes" if edited_file == decrypted_input

            decrypted_parser = Parser::ParserFactory.decrypted_parser
            edited_tokens = decrypted_parser.parse(edited_file)
            encrypted_output = edited_tokens.map{ |t| t.to_decrypted }.join

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
