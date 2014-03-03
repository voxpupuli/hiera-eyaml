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

        def self.snakecase string
          return string if string !~ /[A-Z]/
          string.split(/(?=[A-Z])/).collect {|x| x.downcase}.join("_")
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
          file.close!

          file = File.open(path, "w")
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

        def self.find_closest_class args
          parent_class = args[ :parent_class ]
          class_name = args[ :class_name ]
          constants = parent_class.constants
          candidates = []
          constants.each do | candidate |
            candidates << candidate.to_s if candidate.to_s.downcase == class_name.downcase
          end
          if candidates.count > 0
            parent_class.const_get candidates.first
          else
            nil
          end
        end

        def self.require_dir classdir
          num_class_hierarchy_levels = self.to_s.split("::").count - 1 
          root_folder = File.dirname(__FILE__) + "/" + Array.new(num_class_hierarchy_levels).fill("..").join("/")
          class_folder = root_folder + "/" + classdir
          Dir[File.expand_path("#{class_folder}/*.rb")].uniq.each do |file|
            # puts "Requiring file: #{file}"
            require file
          end
        end

        def self.find_all_subclasses_of args
          parent_class = args[ :parent_class ]
          constants = parent_class.constants
          candidates = []
          constants.each do | candidate |
            candidates << candidate.to_s.split('::').last if parent_class.const_get(candidate).class.to_s == "Class"
          end
          candidates
        end 

        def self.hiera?
          "hiera".eql? Eyaml::Options[:source]
        end

        def self.structure_message messageinfo
          message = {:from => "hiera-eyaml-core"}
          case messageinfo.class.to_s
          when 'Hash'
            message.merge!(messageinfo)
          else
            message.merge!({:msg => messageinfo.to_s})
          end
        end

        def self.warn messageinfo
          message = self.structure_message messageinfo
          message = "[#{message[:from]}] !!! #{message[:msg]}"
          if self.hiera?
            Hiera.warn message
          else
            STDERR.puts message
          end
        end

        def self.info messageinfo
          message = self.structure_message messageinfo
          message = "[#{message[:from]}] #{message[:msg]}"
          if self.hiera?
            Hiera.debug message if Eyaml.verbosity_level > 0
          else
            STDERR.puts message if Eyaml.verbosity_level > 0
          end
        end

        def self.debug messageinfo
          message = self.structure_message messageinfo
          message = "[#{message[:from]}] #{message[:msg]}"
          if self.hiera?
            Hiera.debug message if Eyaml.verbosity_level > 1
          else
            STDERR.puts message if Eyaml.verbosity_level > 1
          end
        end

      end
    end
  end
end
