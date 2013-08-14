Feature: eyaml hiera integration

  In order to use eyaml as a hiera plugin
  As a developer using hiera-eyaml
  I want to verify that hiera-eyaml works within puppet and hiera

  Scenario: verify puppet3 with hiera can use hiera-eyaml to decrypt data
    When I run `rm -f /tmp/eyaml_puppettest.1 /tmp/eyaml_puppettest.2 /tmpeyaml_puppettest.3 2>/dev/null`
    When I run `puppet apply --confdir ./puppet --debug --verbose puppet/manifests/init.pp`
    Then the output should match /good night/
    And the output should match /and good luck/