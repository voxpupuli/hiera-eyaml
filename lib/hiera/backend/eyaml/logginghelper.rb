require 'tempfile'
require 'fileutils'

class Hiera
  module Backend
    module Eyaml
      class LoggingHelper

        def self.structure_message messageinfo
          message = {:from => "hiera-eyaml-core"}
          case messageinfo.class.to_s
          when 'Hash'
            message.merge!(messageinfo)
          else
            message.merge!({:msg => messageinfo.to_s})
          end
          message[:prefix] = "[#{message[:from]}]"
          message[:spacer] = " #{' ' * message[:from].length} "
          formatted_output = message[:msg].split("\n").each_with_index.map do |line, index|
            if index == 0
              "#{message[:prefix]} #{line}"
            else
              "#{message[:spacer]} #{line}"
            end
          end
          formatted_output.join "\n"
        end

        def self.warn messageinfo
          self.print_message({ :message => self.structure_message( messageinfo ), :hiera_loglevel => :warn, :cli_color => :red })
        end

        def self.info messageinfo
          self.print_message({ :message => self.structure_message( messageinfo ), :hiera_loglevel => :debug, :cli_color => :white, :threshold => 0 })
        end

        def self.debug messageinfo
          self.print_message({ :message => self.structure_message( messageinfo ), :hiera_loglevel => :debug, :cli_color => :green, :threshold => 1 })
        end

        def self.trace messageinfo
          self.print_message({ :message => self.structure_message( messageinfo ), :hiera_loglevel => :debug, :cli_color => :blue, :threshold => 2 })
        end

        def self.print_message( args )
          message        = args[:message] ||= ""
          hiera_loglevel = args[:hiera_loglevel] ||= :debug
          cli_color      = args[:cli_color] ||= :blue
          threshold      = args[:threshold]

          if self.hiera?
            Hiera.send(hiera_loglevel, message) if threshold.nil? or Eyaml.verbosity_level > threshold
          else
            STDERR.puts self.colorize( message, cli_color ) if threshold.nil? or Eyaml.verbosity_level > threshold
          end
        end

        def self.colorize message, color
          suffix = "\e[0m"
          prefix = case color
          when :red
            "\e[31m"
          when :green
            "\e[32m"
          when :blue
            "\e[34m"
          else #:white
            "\e[0m"
          end
          "#{prefix}#{message}#{suffix}"
        end

        def self.hiera?
          "hiera".eql? Eyaml::Options[:source]
        end

      end
    end
  end
end
