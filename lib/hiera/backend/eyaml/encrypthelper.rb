require 'tempfile'
require 'fileutils'

class Hiera
  module Backend
    module Eyaml
      class EncryptHelper
        def self.write_important_file(args)
          require 'hiera/backend/eyaml/highlinehelper'
          filename = args[:filename]
          content = args[:content]
          mode = args[:mode]
          if File.file?("#{filename}") && !(HighlineHelper.confirm? "Are you sure you want to overwrite \"#{filename}\"?")
            raise StandardError,
                  'User aborted'
          end
          open("#{filename}", 'w') do |io|
            io.write(content)
          end
          File.chmod(mode, filename) unless mode.nil?
        end

        def self.ensure_key_dir_exists(key_file)
          key_dir = File.dirname key_file

          return if File.directory? key_dir

          begin
            FileUtils.mkdir_p key_dir
            LoggingHelper.info "Created key directory: #{key_dir}"
          rescue StandardError
            raise StandardError, "Cannot create key directory: #{key_dir}"
          end
        end
      end
    end
  end
end
