require 'hiera/backend/eyaml/commands/command'

class Hiera
  module Backend
    module Eyaml
      module Commands

        class Createkeys < Eyaml::Commands::Command

          def self.options 
            []
          end

          def self.description
            "create a set of keys with which to encrypt/decrypt eyaml data"
          end

          def self.execute
            encryptor = Encryptor.find Eyaml.default_encryption_scheme
            encryptor.create_keys
            nil
          end

        end

      end
    end
  end
end
