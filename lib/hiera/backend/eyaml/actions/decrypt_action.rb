require 'hiera/backend/eyaml/utils'

module Hiera
  module Backend
    module Eyaml
      module Actions

        class DecryptAction

          def self.execute options
            data = options[:input_data]
            encryptions = options[:encryptions]
            encryptions.each do |encryption_method, encryption_class|
              encryptor = encryption_class.new :data => data, :options => options
              data = encryptor.decrypt
            end
            data
          end

        end

      end
    end
  end
end
