require 'hiera/backend/eyaml/utils'

module Hiera
  module Backend
    module Eyaml
      module Actions

        class CreateKeys

          def self.execute options
            encryptor.create_keys
            exit 0
          end

      end
    end
  end
end
