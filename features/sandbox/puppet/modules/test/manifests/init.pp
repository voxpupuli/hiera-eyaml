class test::run {

  file { "/tmp/eyaml_puppettest.1":
    ensure => present,
    content => hiera("plaintext_string"),
  }

  file { "/tmp/eyaml_puppettest.2":
    ensure => present,
    content => hiera("encrypted_string"),
  }

  file { "/tmp/eyaml_puppettest.3":
    ensure => present,
    content => inline_template("<%= scope.function_hiera(['encrypted_string']) %>"),
  }

}