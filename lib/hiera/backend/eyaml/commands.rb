require 'rubygems'

class Hiera
  module Backend
    module Eyaml
      class Commands

        @@commands = []

        def self.register
          
        end

        def self.commands
          @@commands
        end

      end
    end
  end
end