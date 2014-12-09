require 'hiera/backend/eyaml/CLI'
require 'hiera/backend/eyaml/encryptors/pkcs7'

class Hiera
  module Backend
    module Eyaml

      describe CLI do
        describe '.execute' do

          before(:each) do
            ARGV.clear
          end

          # Sample Integration test
          # it 'encrypts a string' do
          #   ARGV.push('encrypt')
          #   ARGV.push('hello')
          #   ARGV.push('-s')
          #
          #   Hiera::Backend::Eyaml::Encryptors::Pkcs7.register
          #   CLI.parse
          #   CLI.execute
          # end

        end
      end

    end
  end
end
