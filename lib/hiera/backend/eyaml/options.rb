class Hiera
  module Backend
    module Eyaml
      class Options
        def self.[]=(key, value)
          @@options ||= {}
          @@options[key.to_sym] = value
        end

        def self.[](key)
          @@options ||= {}
          @@options[key.to_sym]
        end

        def self.set(hash)
          @@options = {}
          hash.each do |k, v|
            @@options[k.to_sym] = v
          end
        end

        def self.trace
          LoggingHelper.trace 'Dump of eyaml tool options dict:'
          LoggingHelper.trace '--------------------------------'
          @@options.each do |k, v|
            LoggingHelper.trace format '%18s %-18s = %18s %-18s', "(#{k.class.name})", k.to_s, "(#{v.class.name})",
                                       v.to_s
          rescue StandardError
            LoggingHelper.trace format '%18s %-18s = %18s %-18s', "(#{k.class.name})", k.to_s, "(#{v.class.name})", '<unprintable>' # case where v is binary
          end
          LoggingHelper.trace '--------------------------------'
        end
      end
    end
  end
end
