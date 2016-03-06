require 'highline/import'

class Hiera
  module Backend
    module Eyaml
      class HighlineHelper

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

      end
    end
  end
end
