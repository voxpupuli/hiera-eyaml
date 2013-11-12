Feature: eyaml hiera integration

  In order to use eyaml as a hiera plugin
  As a developer using hiera-eyaml
  I want to verify that hiera-eyaml works within puppet and hiera

  Scenario: verify puppet3 with hiera can use hiera-eyaml to decrypt data
    When I run `rm -f /tmp/eyaml_puppettest.* 2>/dev/null`
    When I run `puppet apply --confdir ./puppet --node_name_value localhost puppet/manifests/init.pp`
    Then the file "/tmp/eyaml_puppettest.1" should match /^good night$/
    Then the file "/tmp/eyaml_puppettest.2" should match /^and good luck$/
    Then the file "/tmp/eyaml_puppettest.3" should match /^and good luck$/
    Then the file "/tmp/eyaml_puppettest.4" should match /^and good luck$/
    Then the file "/tmp/eyaml_puppettest.5" should match /^gangs of new york$/