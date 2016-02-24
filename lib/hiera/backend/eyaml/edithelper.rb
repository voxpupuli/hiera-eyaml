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

      end
    end
  end
end
