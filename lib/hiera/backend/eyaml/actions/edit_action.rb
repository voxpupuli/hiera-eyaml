require 'hiera/backend/eyaml/utils'

module Hiera
  module Backend
    module Eyaml
      module Actions
  
        class EditAction

          def self.execute options
            decrypted_input = encryptor.decrypt
            decrypted_file = Utils.write_tempfile decrypted_input
            editor = Utils.find_editor 
            system editor, decrypted_file
            status = $?
            raise StandardError, "Editor #{editor} has not exited?" unless status.exited?
            raise StandardError, "Editor did not exit successfully (exit code #{status.exitstatus}), aborting" unless status.exitstatus  #TODO: The file is left on the disk
            raise StandardError, "File was moved by editor" unless File.file? decrypted_file
            edited_file = File.read decrypted_file
            Utils.shred_file :file => decrypted_file, :num_bytes => [edited_file.length, decrypted_input.length].max
            raise StandardError, "Edited file is blank" if edited_file.empty?
            raise StandardError, "No changes" if edited_file == decrypted_input
            reencryptor = encryptor_class.new(edited_file, options)
            File.open(options[:eyaml], 'w') { |file| 
              file.write(reencryptor.encrypt)
            }
          end

        end

      end
    end
  end
end
