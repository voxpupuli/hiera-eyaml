require 'hiera/backend/eyaml'
require 'hiera/backend/eyaml/utils'
require 'hiera/backend/eyaml/options'
require 'hiera/backend/eyaml/parser/parser'
require 'hiera/backend/eyaml/subcommand'

class Hiera
  module Backend
    module Eyaml
      module Subcommands

        class Decrypt < Subcommand

          def self.options
            [{:name => :string,
              :description => "Source input is a string provided as an argument",
              :short => 's', 
              :type => :string},
             {:name => :file,
              :description => "Source input is a regular file",
              :short => 'f',
              :type => :string},
             {:name => :eyaml,
              :description => "Source input is an eyaml file",
              :short => 'e',
              :type => :string},
             {:name => :stdin,
              :description => "Source input is taken from stdin",
              :short => :none}
            ]
          end

          def self.description
            "decrypt some data"
          end

          def self.validate options
            sources = [:eyaml, :password, :string, :file, :stdin].collect {|x| x if options[x]}.compact
            Trollop::die "You must specify a source" if sources.count.zero?
            Trollop::die "You can only specify one of (#{sources.join(', ')})" if sources.count > 1
            options[:source] = sources.first

            options[:input_data] = case options[:source]
            when :stdin
              STDIN.read
            when :string
              options[:string]
            when :file
              File.read options[:file]
            when :eyaml
              File.read options[:eyaml]
            end
            options
          end

          def self.execute
            parser = Parser::ParserFactory.encrypted_parser
            tokens = parser.parse(Eyaml::Options[:input_data])
            case Eyaml::Options[:source]
              when :eyaml
                decrypted = tokens.map{ |token| token.to_decrypted }
                decrypted.join
              else
                decrypted = tokens.map{ |token|
                  case token.class.name
                    when /::EncToken$/
                      token.plain_text
                    else
                      token.match
                  end
                }
                decrypted.join
            end
          end

        end

      end
    end
  end
end
