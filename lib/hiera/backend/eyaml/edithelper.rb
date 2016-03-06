require 'hiera/backend/eyaml/logginghelper'

class Hiera
  module Backend
    module Eyaml
      class EditHelper

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
            pathdirs = ENV['PATH'].split(File::PATH_SEPARATOR)
            paths += pathdirs.collect { |dir| paths.collect { |path| File.expand_path(path, dir) } }.flatten
            editorfile = paths.select { |path|
              FileTest.file?(path) || ! extensions.select {|ext| FileTest.file?(path + ext) }.empty?
            }.first
            raise StandardError, "Editor not found. Please set your EDITOR env variable" if editorfile.nil?
            raw_command = paths[(paths.index editorfile) % pieces.size]
            editor = "\"#{editorfile}\"#{editor[raw_command.size()..-1]}"
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
          file.chmod(0600)
          if ENV['OS'] == 'Windows_NT'
            # Windows doesn't support chmod
            icacls = 'C:\Windows\system32\icacls.exe'
            if File.executable? icacls
              current_user = `C:\\Windows\\system32\\whoami.exe`.chomp
              # Use ACLs to restrict access to the current user only
              command = %Q{#{icacls} "#{file.path}" /grant:r "#{current_user}":f /inheritance:r}
              system "#{command} >NUL 2>&1"
            end
          end
          file.puts data_to_write
          file.close

          LoggingHelper::debug "Wrote temporary file: #{path}"

          path
        end

      end
    end
  end
end
