require 'hiera/backend/eyaml/utils'
require 'hiera/backend/eyaml/options'

class Hiera
  module Backend
    module Eyaml
      module Actions

        class CreatekeysAction

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
