Feature: eyaml hiera integration

  In order to use eyaml as a hiera plugin
  As a developer using hiera-eyaml
  I want to verify that hiera-eyaml works within puppet and hiera

  Scenario: verify puppet3 with hiera can use hiera-eyaml to decrypt data
    When I run `rm -f /tmp/eyaml_puppettest.1 /tmp/eyaml_puppettest.2 /tmp/eyaml_puppettest.3 /tmp/eyaml_puppettest.4 2>/dev/null`
    When I run `puppet apply --confdir ./puppet --node_name_value localhost puppet/manifests/init.pp`
    When I run `cat /tmp/eyaml_puppettest.1`
    Then the output should match /good night/
    When I run `cat /tmp/eyaml_puppettest.2`
    Then the output should match /and good luck/
    When I run `cat /tmp/eyaml_puppettest.3`
    Then the output should match /and good luck/
    When I run `cat /tmp/eyaml_puppettest.4`
    Then the output should match /and good luck/