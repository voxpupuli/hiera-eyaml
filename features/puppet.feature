Feature: eyaml hiera integration

  In order to use eyaml as a hiera plugin
  As a developer using hiera-eyaml
  I want to verify that hiera-eyaml works within puppet and hiera

  Scenario: verify puppet with hiera can use hiera-eyaml to decrypt data
    When I run `rm -f /tmp/eyaml_puppettest.* 2>/dev/null`
    When I run `puppet apply --confdir ./puppet --node_name_value localhost puppet/manifests/init.pp`
    Then the output should contain "/tmp/eyaml_puppettest"
    Then the file "/tmp/eyaml_puppettest.1" should match /^good night$/
    Then the file "/tmp/eyaml_puppettest.2" should match /^and good luck$/
    Then the file "/tmp/eyaml_puppettest.3" should match /^and good luck$/
    Then the file "/tmp/eyaml_puppettest.4" should match /^and good luck$/
    Then the file "/tmp/eyaml_puppettest.5" should match /^gangs of new york$/


  Scenario: verify puppet and facter for correct hash merge with incorrect fact
    Given I set FACTER_fact to "not-existcity"
    When I run `rm -f /tmp/eyaml_puppettest.* 2>/dev/null`
    When I run `puppet apply --confdir ./puppet-hiera-merge --node_name_value localhost puppet-hiera-merge/manifests/init.pp`
    Then the output should contain "/tmp/eyaml_puppettest"
    Then the file "/tmp/eyaml_puppettest.1" should match /^good night$/
    Then the file "/tmp/eyaml_puppettest.2" should match /^great to see you$/
    Then the file "/tmp/eyaml_puppettest.3" should match /good luck/
    Then the file "/tmp/eyaml_puppettest.4" should match /"here": "we go again!"/
    Then the file "/tmp/eyaml_puppettest.5" should match /^gangs of new york\nis to the warriors$/

  Scenario: verify puppet and facter for correct hash merge
    Given I set FACTER_fact to "city"
    When I run `rm -f /tmp/eyaml_puppettest.* 2>/dev/null`
    When I run `puppet apply --confdir ./puppet-hiera-merge --node_name_value localhost puppet-hiera-merge/manifests/init.pp`
    Then the output should contain "/tmp/eyaml_puppettest"
    Then the file "/tmp/eyaml_puppettest.1" should match /^rise and shine$/
    Then the file "/tmp/eyaml_puppettest.2" should match /^break a leg$/
    Then the file "/tmp/eyaml_puppettest.3" should match /it'll be alright on the night/
    Then the file "/tmp/eyaml_puppettest.4" should match /"here": "be rabbits"/
    Then the file "/tmp/eyaml_puppettest.4" should match /"see": "no evil"/
    Then the file "/tmp/eyaml_puppettest.5" should match /^source code\nis to donny darko$/
