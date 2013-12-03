require 'hiera/backend/eyaml/subcommand'

class Hiera
  module Backend
    module Eyaml
      module Subcommands

        class Createkeys < Subcommand

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
