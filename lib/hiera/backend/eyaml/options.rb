class Hiera
  module Backend
    module Eyaml
      class Options

        def self.[]= key, value
          @@options[ key ] = value
        end

        def self.[] key
          @@options[ key ]
        end

        def self.set array
          @@options = array
        end

      end
    end
  end
end
