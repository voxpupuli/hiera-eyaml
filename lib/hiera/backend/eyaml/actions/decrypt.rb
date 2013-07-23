require 'hiera/backend/eyaml/utils'

module Hiera
  module Backend
    module Eyaml
      module Actions

        class Decrypt

          def self.execute options
            data = options[:input_data]
            options[:encryptions].keys.each do |encryption_method, encryption_class|
              encryptor = encryption_class.new :data => data, :options => options
              data = encryptor.encrypt
            end
            data
          end

        end

      end
    end
  end
end
