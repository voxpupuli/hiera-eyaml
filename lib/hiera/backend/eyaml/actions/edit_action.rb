require 'hiera/backend/eyaml/utils'
require 'hiera/backend/eyaml/actions/decrypt_action'
require 'hiera/backend/eyaml/actions/encrypt_action'
require 'hiera/backend/eyaml/options'
require 'hiera/backend/eyaml/parser/parser'
require 'highline/import'

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

            begin
              system "#{editor} #{decrypted_file}"
              status = $?

              raise StandardError, "File was moved by editor" unless File.file? decrypted_file
              edited_file = File.read decrypted_file

              raise StandardError, "Editor #{editor} has not exited?" unless status.exited?
              raise StandardError, "Editor did not exit successfully (exit code #{status.exitstatus}), aborting" unless status.exitstatus == 0

              raise StandardError, "Edited file is blank" if edited_file.empty?

              if edited_file == decrypted_input
                Utils.info "No changes detected, exiting"
              else
                decrypted_parser = Parser::ParserFactory.decrypted_parser
                edited_tokens = decrypted_parser.parse(edited_file)

                # check that the tokens haven't been copy / pasted
                used_ids = edited_tokens.find_all{ |t| t.class.name =~ /::EncToken$/ and !t.id.nil? }.map{ |t| t.id }
                if used_ids.length != used_ids.uniq.length
                    raise RecoverableError, "A duplicate DEC(ID) was found so I don't know how to proceed. This is probably because you copy and pasted a value - if you do this please delete the ID in parentheses"
                end

                # replace untouched values with the source values
                edited_denoised_tokens = edited_tokens.map{ |token|
                  if token.class.name =~ /::EncToken$/ && !token.id.nil?
                    old_token = tokens[token.id]
                    if old_token.plain_text.eql? token.plain_text
                      old_token
                    else
                      token
                    end
                  else
                    token
                  end
                }

                encrypted_output = edited_denoised_tokens.map{ |t| t.to_encrypted }.join

                filename = Eyaml::Options[:eyaml]
                File.open("#{filename}", 'w') { |file|
                  file.write encrypted_output
                }
              end
            rescue RecoverableError => e
              Utils.info e
              if agree "Return to the editor to try again?"
                retry
              else
                raise e
              end
            ensure
              Utils.secure_file_delete :file => decrypted_file, :num_bytes => [edited_file.length, decrypted_input.length].max
            end

            nil
          end

        end

      end
    end
  end
end
