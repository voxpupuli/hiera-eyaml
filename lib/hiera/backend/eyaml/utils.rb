require 'highline/import'
require 'tempfile'

class Hiera
  module Backend
    module Eyaml
      class Utils

        def self.default_encryption
          "PKCS7"
        end

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

        def self.read_password
          ask("Enter password: ") {|q| q.echo = "*" }
        end

        def self.format args
          data = args[:data]
          data_as_block = data.split("\n").join("\n    ")
          data_as_string = data.split("\n").join("")
          structure = args[:structure]

          case structure
          when "examples"
            "string: #{data_as_string}\n\n" +
            "OR\n\n" +
            "block: >\n" +
            "    #{data_as_block}" 
          when "block"
            "    #{data_as_block}" 
          when "string"
            "#{data_as_string}"
          else
            data.to_s
          end

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
          File.delete file
        end

        def self.write_tempfile data_to_write
          file = Tempfile.open('eyaml_edit')
          path = file.path

          file.puts data_to_write
          file.close

          path
        end

        def self.find_closest_class parent_class, classname
          constants = parent_class.constants
          candidates = []
          constants.each do | candidate |
            candidates << candidate.to_s if candidate.to_s.downcase == classname.downcase
          end
          if candidates.count > 0
            parent_class.const_get candidates.first
          else
            nil
          end
        end

        def self.camelcase string
          return string if string !~ /_/ && string =~ /[A-Z]+.*/
          string.split('_').map{|e| e.capitalize}.join
        end

        def self.find_encryptor encryptor_name
          encryptor_module = Module.const_get('Hiera').const_get('Backend').const_get('Eyaml').const_get('Encryptors')
          encryptor_class = self.find_closest_class encryptor_module, encryptor_name
          raise StandardError, "Could not find encryptor: #{encryptor_name}. Try gem install hiera-eyaml-#{encryptor_name} ?" if encryptor_class.nil?
          encryptor_class
        end

        def self.get_encryptors encryptions
          encryptions.keys.each do |encryption_method|
            encryptor = nil
            encryptor_class = nil
            begin
              require "hiera/backend/eyaml/encryptors/#{encryption_method}"
            rescue LoadError
              raise StandardError, "Encryption method #{encryption_method} not available. Have you tried gem install hiera-eyaml-#{encryption_method} ?"
            end
            encryptions[ encryption_method ] = Utils.find_encryptor encryption_method
          end
          encryptions
        end


      end
    end
  end
end
