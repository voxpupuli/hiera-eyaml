require 'spec/spec_helper'
require 'spec/keys'
require 'hiera/backend/eyaml/CLI'
require 'hiera/backend/eyaml/encryptors/pkcs7'

class Hiera
  module Backend
    module Eyaml
      describe CLI do

        describe '.execute' do
          before(:each) do
            File.stubs(:read).with('./keys/public_key.pkcs7.pem').returns Eyaml::Keys.pkcs7_public_key
            File.stubs(:read).with('./keys/private_key.pkcs7.pem').returns Eyaml::Keys.pkcs7_private_key
          end
          # Sample Integration test
          it 'encrypts a string' do
            ARGV.clear
            ARGV.push('encrypt')
            ARGV.push('-s')
            ARGV.push('hello')

            Hiera::Backend::Eyaml::Encryptors::Pkcs7.register
            expect {
              CLI.parse
              CLI.execute
            }.to output(/string: ENC\[PKCS7,.*\]/).to_stdout
          end
        end

      end
    end
  end
end
