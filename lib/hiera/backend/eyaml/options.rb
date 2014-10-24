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

        def self.trace
          Utils::trace "Dump of eyaml tool options dict:"
          Utils::trace "--------------------------------"
          @@options.each do |k, v|
            begin
              Utils::trace sprintf "%18s %-18s = %18s %-18s", "(#{k.class.name})", k.to_s, "(#{v.class.name})", v.to_s
            rescue
              Utils::trace sprintf "%18s %-18s = %18s %-18s", "(#{k.class.name})", k.to_s, "(#{v.class.name})", "<unprintable>" # case where v is binary
            end
          end
          Utils::trace "--------------------------------"
        end

      end
    end
  end
end
