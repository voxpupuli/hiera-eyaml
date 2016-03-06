require 'hiera/backend/eyaml/edithelper'
require 'hiera/backend/eyaml/highlinehelper'
require 'hiera/backend/eyaml/options'
require 'hiera/backend/eyaml/parser/parser'
require 'hiera/backend/eyaml/subcommand'

class Hiera
  module Backend
    module Eyaml
      module Subcommands

        class Edit < Subcommand

          def self.options
            [{ :name => :no_preamble,
               :description => "Don't prefix edit sessions with the informative preamble" }]
          end

          def self.description
            "edit an eyaml file"
          end

          def self.helptext
            "Usage: eyaml edit [options] <some-eyaml-file>"
          end

          def self.prefix
            '#|'
          end

          def self.preamble
            tags = (["pkcs7"] + Plugins.plugins.collect {|plugin|
              plugin.name.split("hiera-eyaml-").last
            }).collect{|name| Encryptor.find(name).tag}

            preamble = <<-eos
This is eyaml edit mode. This text (lines starting with #{self.prefix} at the top of the
file) will be removed when you save and exit.
 - To edit encrypted values, change the content of the DEC(<num>)::PKCS7[]!
   block#{(tags.size>1) ? " (or #{tags.drop(1).collect {|tag| "DEC(<num>)::#{tag}[]!" }.join(' or ')})." : '.' }
   WARNING: DO NOT change the number in the parentheses.
 - To add a new encrypted value copy and paste a new block from the
   appropriate example below. Note that:
    * the text to encrypt goes in the square brackets
    * ensure you include the exclamation mark when you copy and paste
    * you must not include a number when adding a new block
   e.g. #{tags.collect {|tag| "DEC::#{tag}[]!" }.join(' -or- ')}
eos

            preamble.gsub(/^/, "#{self.prefix} ")
          end

          def self.validate options
            Trollop::die "You must specify an eyaml file" if ARGV.empty?
            options[:source] = :eyaml
            options[:eyaml] = ARGV.shift
            if File.exists? options[:eyaml]
              begin
                options[:input_data] = File.read options[:eyaml]
              rescue
                raise StandardError, "Could not open file for reading: #{options[:eyaml]}"
              end
            else
              LoggingHelper.info "#{options[:eyaml]} doesn't exist, editing new file"
              options[:input_data] = "---"
            end
            options
          end

          def self.execute
            editor = EditHelper.find_editor

            encrypted_parser = Parser::ParserFactory.encrypted_parser
            tokens = encrypted_parser.parse Eyaml::Options[:input_data]
            decrypted_input = tokens.each_with_index.to_a.map{|(t,index)| t.to_decrypted :index => index}.join
            decrypted_file_content = Eyaml::Options[:no_preamble] ? decrypted_input : (self.preamble + decrypted_input)

            begin
              decrypted_file = EditHelper.write_tempfile decrypted_file_content unless decrypted_file
              system "#{editor} \"#{decrypted_file}\""
              status = $?

              raise StandardError, "File was moved by editor" unless File.file? decrypted_file
              raw_edited_file = File.read decrypted_file
              # strip comments at start of file
              edited_file = raw_edited_file.split($/,-1).drop_while {|line| line.start_with?(self.prefix)}.join($/)

              raise StandardError, "Editor #{editor} has not exited?" unless status.exited?
              raise StandardError, "Editor did not exit successfully (exit code #{status.exitstatus}), aborting" unless status.exitstatus == 0
              raise StandardError, "Edited file is blank" if edited_file.empty?

              if edited_file == decrypted_input
                LoggingHelper.info "No changes detected, exiting"
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
              LoggingHelper.info e
              if agree "Return to the editor to try again?"
                retry
              else
                raise e
              end
            ensure
              EditHelper.secure_file_delete :file => decrypted_file, :num_bytes => [edited_file.length, decrypted_input.length].max
            end

            nil
          end

        end

      end
    end
  end
end
