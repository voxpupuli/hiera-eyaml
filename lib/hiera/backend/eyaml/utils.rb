require 'tempfile'
require 'fileutils'
require 'hiera/backend/eyaml/logginghelper'

class Hiera
  module Backend
    module Eyaml
      class Utils

        def self.camelcase string
          return string if string !~ /_/ && string =~ /[A-Z]+.*/
          string.split('_').map{|e| e.capitalize}.join
        end

        def self.snakecase string
          return string if string !~ /[A-Z]/
          string.split(/(?=[A-Z])/).collect {|x| x.downcase}.join("_")
        end

        def self.find_closest_class args
          parent_class = args[ :parent_class ]
          class_name = args[ :class_name ]
          constants = parent_class.constants
          candidates = []
          constants.each do | candidate |
            candidates << candidate.to_s if candidate.to_s.downcase == class_name.downcase
          end
          if candidates.count > 0
            parent_class.const_get candidates.first
          else
            nil
          end
        end

        def self.require_dir classdir
          num_class_hierarchy_levels = self.to_s.split("::").count - 1 
          root_folder = File.dirname(__FILE__) + "/" + Array.new(num_class_hierarchy_levels).fill("..").join("/")
          class_folder = root_folder + "/" + classdir
          Dir[File.expand_path("#{class_folder}/*.rb")].uniq.each do |file|
            LoggingHelper.trace "Requiring file: #{file}"
            require file
          end
        end

        def self.find_all_subclasses_of args
          parent_class = args[ :parent_class ]
          constants = parent_class.constants
          candidates = []
          constants.each do | candidate |
            candidates << candidate.to_s.split('::').last if parent_class.const_get(candidate).class.to_s == "Class"
          end
          candidates
        end 

        def self.hiera?
          "hiera".eql? Eyaml::Options[:source]
        end

      end
    end
  end
end
