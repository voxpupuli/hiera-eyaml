require 'hiera/backend/eyaml/utils'

class Hiera
  module Backend
    module Eyaml
      module Actions

        class CreatekeysAction

          def self.execute options
            encryptions = options[:encryptions]
            encryptions.each do |encryption_method, encryption_class|
              encryptor = encryption_class.new :data => "", :options => options
              encryptor.create_keys
            end
            nil            
          end

        end

      end
    end
  end
end
