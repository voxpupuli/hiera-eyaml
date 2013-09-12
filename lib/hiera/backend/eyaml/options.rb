class Hiera
  module Backend
    module Eyaml
      class Options

        def self.[]= key, value
          @@options ||= {}
          @@options[ key.to_sym ] = value
        end

        def self.[] key
          @@options ||= {}
          @@options[ key.to_sym ]
        end

        def self.set hash
          @@options = {}
          hash.each do |k, v|
            @@options[ k.to_sym ] = v
          end
        end

        def self.debug
          Utils::debug "Dump of eyaml tool options dict:"
          Utils::debug "--------------------------------"
          @@options.each do |k, v|
            Utils::debug "#{k.class.name}:#{k} = #{v.class.name}:#{v}"
          end
          Utils::debug ""
        end

      end
    end
  end
end
