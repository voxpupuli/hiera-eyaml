class test::run {

  file { "/tmp/eyaml_puppettest.1":
    ensure => present,
    content => hiera("plaintext_string"),
  }

  file { "/tmp/eyaml_puppettest.2":
    ensure => present,
    content => hiera("encrypted_string"),
  }

  # This is ugly, but cross-compatibility between early puppet 3 manifests and puppet 4
  # manifests is basically non-existent.  Assuming we support both...
  if ($::puppetversion =~ /^4/){
    file { "/tmp/eyaml_puppettest.3":
      ensure => present,
      content => inline_template("<%= scope.compiler.loaders.private_environment_loader.load(:function,'hiera').call(scope, 'encrypted_string')  %>"),
    }
  } else {
    file { "/tmp/eyaml_puppettest.3":
      ensure => present,
      content => inline_template("<%= scope.function_hiera(['encrypted_string'])  %>"),
    }
  }

  file { "/tmp/eyaml_puppettest.4":
    ensure => present,
    content => hiera("default_encrypted_string"),
  }

  file { "/tmp/eyaml_puppettest.5":
    ensure => present,
    content => hiera("encrypted_block"),
  }

}
