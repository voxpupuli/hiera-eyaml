class Hiera
  module Backend
    module Eyaml

      VERSION = "1.4.0"
      DESCRIPTION = "Hiera-eyaml is a backend for Hiera which provides OpenSSL encryption/decryption for Hiera properties"
      USAGE = <<-EOS
Usage:
  eyaml <command> [options] 
  eyaml edit file.eyaml       # edit a file
  eyaml encrypt -s some-string   # encrypt a string
  eyaml encrypt --password       # encrypt a password 
  eyaml enc-e -f file.txt      # encrypt a file
  cat file.txt | eyaml -e   # encrypt a file on a pipe
EOS

      def self.subcommand= command
        @@subcommand = command
      end

      def self.subcommand
        @@subcommand
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

      def self.subcommands= commands
        @@subcommands = commands
      end

      def self.subcommands
        @@subcommands
      end
      
    end
  end
end

