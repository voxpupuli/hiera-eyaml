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

          # def self.execute options
          #   data = options[:input_data]
          #   puts "Data is currently #{data}"
          #   puts "Lets go"
          #   data = data.gsub(/ENC\[([^\]]+,)?([^\]]*)\]/) { |match|
          #     puts "Data is currently #{data}"
          #     encryption_method = $1
          #     encryption_method = DEFAULT_ENCRYPTION if encryption_method.nil?
          #     encryption_class = Utils.find_encryptor encryption_method
          #     encryptor = encryption_class.new :data => data, :options => {}
          #     data = encryptor.decrypt
          #     puts "Decrypting with #{encryption_class} - data is now #{data}"
          #   }
          #   data
          # end

        end

      end
    end
  end
end
