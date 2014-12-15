require 'rubygems'
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

        def self.find_gem_specs
          if Gem::VERSION < '1.6.0'
            Gem.source_index.latest_specs
          elsif Gem::VERSION < '1.8.0'
            Gem.source_index.latest_specs(true)
          else
            Gem::Specification.latest_specs(true)
          end
        end

        def self.find_file_in_gem(gem_spec, glob)
          if Gem::VERSION < "1.8.0"
            Gem.searcher.matching_files(gem_spec, glob).first
          else
            gem_spec.matches_for_glob(glob).first
          end
        end

        def self.find_editor
          editor = ENV['EDITOR']
          editor ||= %w{ /usr/bin/sensible-editor /usr/bin/editor /usr/bin/vim /usr/bin/vi }.collect {|e| e if FileTest.executable? e}.compact.first
          raise StandardError, "Editor not found. Please set your EDITOR env variable" if editor.nil?
          if editor.index(' ')
            editor = editor.dup if editor.frozen? # values from ENV are frozen
            editor.gsub!(/([^\\]|^)~/, '\1' + ENV['HOME']) # replace ~ with home unless escaped
            editor.gsub!(/(^|[^\\])"/, '\1') # remove unescaped quotes during processing
            editor.gsub!(/\\ /, ' ') # unescape spaces since we quote paths
            pieces = editor.split(' ')
            paths = pieces.each_with_index.map {|_,x| pieces[0..x].join(' ')}.reverse # get possible paths, starting with longest
            extensions = (ENV['PATHEXT'] || '').split(';') # handle Windows executables
            editorfile = paths.select { |path|
              FileTest.file?(path) || ! extensions.select {|ext| FileTest.file?(path + ext) }.empty?
            }.first
            raise StandardError, "Editor not found. Please set your EDITOR env variable" if editorfile.nil?
            editor = "\"#{editorfile}\"#{editor[editorfile.size()..-1]}"
          end
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
          file.close
          File.delete args[:file]
        end

        def self.write_tempfile data_to_write
          file = Tempfile.open(['eyaml_edit', '.yaml'])
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
            self.trace "Requiring file: #{file}"
            require file
          end
        end

        def self.find_all_subclasses_of(parent_class)
          ObjectSpace.each_object(Class).select { |klass| klass.superclass == parent_class }
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
          message[:prefix] = "[#{message[:from]}]"
          message[:spacer] = " #{' ' * message[:from].length} "
          formatted_output = message[:msg].split("\n").each_with_index.map do |line, index|
            if index == 0
              "#{message[:prefix]} #{line}"
            else
              "#{message[:spacer]} #{line}"
            end
          end
          formatted_output.join "\n"
        end

        def self.warn messageinfo
          self.print_message({ :message => self.structure_message( messageinfo ), :hiera_loglevel => :warn, :cli_color => :red })
        end

        def self.info messageinfo
          self.print_message({ :message => self.structure_message( messageinfo ), :hiera_loglevel => :debug, :cli_color => :white, :threshold => 0 })
        end

        def self.debug messageinfo
          self.print_message({ :message => self.structure_message( messageinfo ), :hiera_loglevel => :debug, :cli_color => :green, :threshold => 1 })
        end

        def self.trace messageinfo
          self.print_message({ :message => self.structure_message( messageinfo ), :hiera_loglevel => :debug, :cli_color => :blue, :threshold => 2 })
        end

        def self.print_message( args )
          message        = args[:message] ||= ""
          hiera_loglevel = args[:hiera_loglevel] ||= :debug
          cli_color      = args[:cli_color] ||= :blue
          threshold      = args[:threshold]

          if self.hiera?
            Hiera.send(hiera_loglevel, message) if threshold.nil? or Eyaml.verbosity_level > threshold
          else
            STDERR.puts self.colorize( message, cli_color ) if threshold.nil? or Eyaml.verbosity_level > threshold
          end
        end

        def self.colorize message, color
          suffix = "\e[0m"
          prefix = case color
          when :red
            "\e[31m"
          when :green
            "\e[32m"
          when :blue
            "\e[34m"
          else #:white
            "\e[0m"
          end
          "#{prefix}#{message}#{suffix}"
        end

      end
    end
  end
end
