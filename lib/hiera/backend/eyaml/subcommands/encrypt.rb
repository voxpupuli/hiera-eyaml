require 'hiera/backend/eyaml/options'
require 'hiera/backend/eyaml/parser/parser'
require 'hiera/backend/eyaml/parser/encrypted_tokens'
require 'hiera/backend/eyaml/subcommand'

class Hiera
  module Backend
    module Eyaml
      module Subcommands

        class Encrypt < Subcommand

          def self.options
            [{:name => :password, 
              :description => "Source input is a password entered on the terminal", 
              :short => 'p'},
             {:name => :string,
              :description => "Source input is a string provided as an argument",
              :short => 's', 
              :type => :string},
             {:name => :file,
              :description => "Source input is a regular file",
              :short => 'f',
              :type => :string},
             {:name => :stdin,
              :description => "Source input is taken from stdin",
              :short => :none},
             {:name => :eyaml,
              :description => "Source input is an eyaml file",
              :short => 'e',
              :type => :string},
             {:name => :output,
              :description => "Output format of final result (examples, block, string)",
              :type => :string,
              :short => 'o',
              :default => "examples"},
             {:name => :label,
              :description => "Apply a label to the encrypted result",
              :short => 'l',
              :type => :string}
            ]
          end

          def self.description
            "encrypt some data"
          end

          def self.validate options
            sources = [:password, :string, :file, :stdin, :eyaml].collect {|x| x if options[x]}.compact
            Trollop::die "You must specify a source" if sources.count.zero?
            Trollop::die "You can only specify one of (#{sources.join(', ')})" if sources.count > 1
            options[:source] = sources.first

            options[:input_data] = case options[:source]
            when :password
              require 'hiera/backend/eyaml/highlinehelper'
              HighlineHelper.read_password
            when :string
              options[:string]
            when :file
              File.read options[:file]
            when :stdin
              STDIN.read
            when :eyaml
              File.read options[:eyaml]
            end
            options

          end

          def self.execute
            case Eyaml::Options[:source]
              when :eyaml
                parser = Parser::ParserFactory.decrypted_parser
                tokens = parser.parse(Eyaml::Options[:input_data])
                encrypted = tokens.map{ |token| token.to_encrypted }
                encrypted.join
              else
                encryptor = Encryptor.find
                ciphertext = encryptor.encode( encryptor.encrypt(Eyaml::Options[:input_data]) )
                token = Parser::EncToken.new(:block, Eyaml::Options[:input_data], encryptor, ciphertext, nil, '    ')
                case Eyaml::Options[:output]
                  when "block"
                    token.to_encrypted :label => Eyaml::Options[:label], :use_chevron => !Eyaml::Options[:label].nil?, :format => :block
                  when "string"
                    token.to_encrypted :label => Eyaml::Options[:label], :format => :string
                  when "examples"
                    string = token.to_encrypted :label => Eyaml::Options[:label] || 'string', :format => :string
                    block = token.to_encrypted :label => Eyaml::Options[:label] || 'block', :format => :block
                    "#{string}\n\nOR\n\n#{block}"
                  else
                    token.to_encrypted :format => :string
                end
            end
          end
        end

      end
    end
  end
end
