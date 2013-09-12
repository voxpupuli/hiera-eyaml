require 'highline/import'
require 'tempfile'
require 'fileutils'

class Hiera
  module Backend
    module Eyaml
      class Utils

        def self.read_password
          ask("Enter password: ") {|q| q.echo = "*" }
        end

        def self.confirm? message
          result = ask("#{message} (y/N): ")
          if result.downcase == "y" or result.downcase == "yes"
            true
          else
            false
          end
        end

        def self.camelcase string
          return string if string !~ /_/ && string =~ /[A-Z]+.*/
          string.split('_').map{|e| e.capitalize}.join
        end

        def self.find_editor
          editor = ENV['EDITOR']
          editor ||= %w{ /usr/bin/sensible-editor /usr/bin/editor /usr/bin/vim /usr/bin/vi }.collect {|e| e if FileTest.executable? e}.compact.first
          raise StandardError, "Editor not found. Please set your EDITOR env variable" if editor.nil?
          editor
        end

        def self.secure_file_delete args
          file = File.open(args[:file], 'r+')
          num_bytes = args[:num_bytes]
          [0xff, 0x55, 0xaa, 0x00].each do |byte|
            file.seek(0, IO::SEEK_SET)
            num_bytes.times { file.print(byte.chr) }
            file.fsync
          end
          File.delete args[:file]
        end

        def self.write_tempfile data_to_write
          file = Tempfile.open('eyaml_edit')
          path = file.path

          file.puts data_to_write
          file.close

          path
        end

        def self.write_important_file args
          filename = args[ :filename ]
          content = args[ :content ]
          mode = args[ :mode ]
          if File.file? "#{filename}"
             raise StandardError, "User aborted" unless Utils::confirm? "Are you sure you want to overwrite \"#{filename}\"?"
          end
          open( "#{filename}", "w" ) do |io|
            io.write(content)
          end
          File.chmod( mode, filename ) unless mode.nil?
        end

        def self.ensure_key_dir_exists key_file
          key_dir = File.dirname key_file

          unless File.directory? key_dir
            begin
              FileUtils.mkdir_p key_dir
              Utils::info "Created key directory: #{key_dir}"
            rescue
              raise StandardError, "Cannot create key directory: #{key_dir}"
            end
          end

        end

        def self.info message
          STDERR.puts message unless Eyaml::Options[:quiet]
        end

        def self.debug message
          STDERR.puts message if Eyaml::Options[:debug]
        end

      end
    end
  end
end
