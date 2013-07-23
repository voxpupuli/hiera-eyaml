require 'highline/import'
require 'tempfile'

module Hiera
  module Backend
    module Eyaml
      class Utils

        def self.ensure_key_dir_exists key_file
          key_dir = File.dirname key_file

          unless File.directory? key_dir
            begin
              Dir.mkdir key_dir
              puts "Created key directory: #{key_dir}"
            rescue
              raise StandardError, "Cannot create key directory: #{key_dir}"
            end
          end

        end

        def self.ask_for_password
          ask("Enter password: ") {|q| q.echo = "*" }
        end

        def self.format args
          data = args[:data]
          structure = args[:structure]

        end

        def self.find_editor
          editor = ENV['EDITOR']
          editor ||= %w{ /usr/bin/sensible-editor /usr/bin/editor /usr/bin/vim /usr/bin/vi }.collect {|e| e if FileTest.executable? e}.compact.first
          raise StandardError, "Editor not found. Please set your EDITOR env variable" if editor.nil?
          editor
        end

        def self.secure_file_delete args
          file = args[:file]
          num_bytes = args[:num_bytes]
          [0xff, 0x55, 0xaa, 0x00].each do |byte|
            file.seek(0, IO::SEEK_SET)
            num_bytes.times { file.print(byte.chr) }
            file.fsync
          end
          File.delete file
        end

        def self.write_tempfile data_to_write
          file = Tempfile.open('eyaml_edit')
          path = file.path

          file.puts data_to_write
          file.close

          path
        end

      end
    end
  end
end
