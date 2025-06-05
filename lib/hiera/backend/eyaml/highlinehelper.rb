require 'highline'

class Hiera
  module Backend
    module Eyaml
      class HighlineHelper
        def self.cli
          HighLine.new($stdin, $stderr)
        end

        def self.read_password
          cli.ask('Enter password: ') { |q| q.echo = '*' }
        end

        def self.confirm?(message)
          result = cli.ask("#{message} (y/N): ")
          %w[y yes].include?(result.downcase) || false
        end
      end
    end
  end
end
