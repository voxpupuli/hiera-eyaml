require 'spec_helper'
require 'keys'
require 'hiera/backend/eyaml/CLI'
require 'hiera/backend/eyaml/encryptors/pkcs7'

class Hiera
  module Backend
    module Eyaml

      class Plugins
        def self.clear_all
          @@plugins = []
          @@commands = []
          @@options = []
        end
      end
      module Commands
        def self.clear_all
          @@commands = {}
        end
      end

      describe CLI do

        before(:each) do
          File.stubs(:read).with('./keys/public_key.pkcs7.pem').returns Eyaml::Keys.pkcs7_public_key
          File.stubs(:read).with('./keys/private_key.pkcs7.pem').returns Eyaml::Keys.pkcs7_private_key

          Plugins.clear_all
          Commands.clear_all
          Hiera::Backend::Eyaml::Encryptors::Pkcs7.register
          ARGV.clear
        end

        it 'encrypts a string' do
          ARGV.push('encrypt')
          ARGV.push('-s')
          ARGV.push('hello')

          expect {
            CLI.parse
            CLI.execute
          }.to output(/string: ENC\[PKCS7,.*\]/).to_stdout
        end

        it 'returns help info' do
          ARGV.push('help')

          expect {
            CLI.parse
            CLI.execute
          }.to output(/Welcome to eyaml.*\n+Usage:/).to_stdout
        end

      end
    end
  end
end
