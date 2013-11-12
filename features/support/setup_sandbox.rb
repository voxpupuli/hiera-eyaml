require 'fileutils'

class SetupSandbox

  def self.create_files test_files

    test_files.each do |test_file, contents|
      extension = test_file.split('.').last
      target_dir = File.dirname(test_file)
      FileUtils.mkdir_p( target_dir ) unless File.directory?( target_dir )
      write_mode = "w"
      write_mode = "wb" if extension == "bin"
      File.open(test_file, write_mode) {|input_file|
        input_file.puts contents
      } unless File.exists?( test_file )
      File.chmod(0755, test_file) if extension == "sh"
    end

  end

end
