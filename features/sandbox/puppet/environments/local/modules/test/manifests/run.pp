class test::run {

  file { "/tmp/eyaml_puppettest.1":
    ensure => present,
    content => hiera("plaintext_string"),
  }

  file { "/tmp/eyaml_puppettest.2":
    ensure => present,
    content => hiera("encrypted_string"),
  }

  # Ugly hack to call hiera() from puppet >= 4
  file { "/tmp/eyaml_puppettest.3":
    ensure => present,
    content => inline_template("<%= scope.compiler.loaders.private_environment_loader.load(:function,'hiera').call(scope, 'encrypted_string')  %>"),
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
