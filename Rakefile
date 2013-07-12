require 'rubygems'
require 'rake/gempackagetask'

spec = Gem::Specification.new do |gem|
    gem.name = "hiera-eyaml"
    gem.version = "1.0.0"
    gem.summary = "OpenSSL Encryption backend for Hiera"
    gem.email = "paultont@example.com"
    gem.author = "Tom Paulton"
    gem.homepage = "http://github.com/TomPaulton/hiera-eyaml"
    gem.description = "Hiera backend for decrypting encrypted yaml properties"
    gem.require_path = "lib"
    gem.files = FileList["lib/**/*"].to_a
    gem.add_dependency('hiera', '>=0.2.0')
end

Rake::GemPackageTask.new(spec) do |pkg|
    pkg.need_tar = true
end

