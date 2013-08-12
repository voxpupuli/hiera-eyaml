class Hiera
  module Backend
    module Eyaml

      VERSION = "1.3.0"

      def self.default_scheme= new_encryption
        @@default_encryption_method = new_encryption
      end

      def self.default_scheme
        @@default_encryption_method ||= "PKCS7"
        @@default_encryption_method
      end

    end
  end
end

