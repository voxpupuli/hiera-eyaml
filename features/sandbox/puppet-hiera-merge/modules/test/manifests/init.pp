class test::run {

  $data = hiera_hash($title)

  File { backup => false }

  file { "/tmp/eyaml_puppettest.1":
    ensure => present,
    content => "${data['plaintext_string']}\n",
  }

  file { "/tmp/eyaml_puppettest.2":
    ensure => present,
    content => "${data['encrypted_string']}\n",
  }

  file { "/tmp/eyaml_puppettest.3":
    ensure => present,
    content => inline_template("<%= require 'json'; JSON.pretty_generate data['encrypted_array'] %>\n"),
  }

  file { "/tmp/eyaml_puppettest.4":
    ensure => present,
    content => inline_template("<%= require 'json'; JSON.pretty_generate data['encrypted_hash'] %>\n"),
  }

  file { "/tmp/eyaml_puppettest.5":
    ensure => present,
    content => "${data['encrypted_block']}\n",
  }

}
