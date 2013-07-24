module Hiera
  module Backend
    module Eyaml
      module Actions

        class EncryptAction

          def self.execute options
            data = options[:input_data]
            encryptions.keys.each do |encryption_method, encryption_class|
              encryptor = encryption_class.new :data => data, :options => options
              data = encryptor.encrypt
            end
            puts Utils.format :data => data, :structure => options[:output_format]
          end

        end

      end
    end
  end
end
