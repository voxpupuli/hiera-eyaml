class Hiera
  module Backend
    module Eyaml

      VERSION = "2.0.6"
      DESCRIPTION = "Hiera-eyaml is a backend for Hiera which provides OpenSSL encryption/decryption for Hiera properties"

      class RecoverableError < StandardError
      end

      def self.default_encryption_scheme= new_encryption
        @@default_encryption_scheme = new_encryption
      end

      def self.default_encryption_scheme
        @@default_encryption_scheme ||= "PKCS7"
        @@default_encryption_scheme
      end

      def self.verbosity_level= new_verbosity_level
        @@debug_level = new_verbosity_level
      end

      def self.verbosity_level
        @@debug_level ||= 1
        @@debug_level
      end

    end
  end
end
