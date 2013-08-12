require 'hiera/backend/eyaml/utils'

class Hiera
  module Backend
    module Eyaml
      module Actions

        class CreatekeysAction

          def self.execute options

            encryptor = Encryptor.find Eyaml.default_encryption
            encryptor.create_keys
            nil

          end

        end

      end
    end
  end
end
