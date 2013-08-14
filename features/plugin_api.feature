Feature: eyaml plugin api

  In order to develop new encryption plugins for eyaml
  As a developer using hiera-eyaml
  I want to use the eyaml tool to exercise the encryption plugins in various ways

  Scenario: verify plugin options are available in eyaml
    When I run `eyaml --help`
    Then the output should match /plaintext-diagnostic-message/
    And the output should match /pkcs7-private-key/
    And the output should match /pkcs7-public-key/

  Scenario: exercise plugin options for a plugin
    When I run `eyaml -n plaintext -c --plaintext-diagnostic-message marker12345`
    Then the output should match /Create_keys: marker12345/

