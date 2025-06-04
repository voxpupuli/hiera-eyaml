require 'highline/import'

class Hiera
  module Backend
    module Eyaml
      class HighlineHelper
        def self.read_password
          ask('Enter password: ') { |q| q.echo = '*' }
        end

        def self.confirm?(message)
          result = ask("#{message} (y/N): ")
          %w[y yes].include?(result.downcase) || false
        end
      end
    end
  end
end
