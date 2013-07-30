require 'hiera/backend/eyaml/utils'
require 'hiera/backend/eyaml/actions/decrypt_action'
require 'hiera/backend/eyaml/actions/encrypt_action'

module Hiera
  module Backend
    module Eyaml
      module Actions
  
        class EditAction

          def self.execute options

            decrypted_input = DecryptAction.execute options
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

            encrypt_options = options.dup
            encryptions = {}
            edited_file.gsub( /DEC(::[^\[]+)\[/ ) { |match|
              encryption_method = $1.slice(2, $1.length)
              encryption_method = Utils.default_encryption if encryption_method.nil?
              encryptions[ encryption_method ] = nil
            }
            encryptions = Utils.get_encryptors encryptions

            encrypt_options[:input_data] = edited_file
            encrypt_options[:encryptions] = encryptions
            encrypt_options[:output] = "raw"

            encrypted_output = EncryptAction.execute encrypt_options

            File.open("#{options[:eyaml]}.new", 'w') { |file| 
              file.write encrypted_output
            }

            true
          end

        end

      end
    end
  end
end
