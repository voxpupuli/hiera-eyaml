Feature: config file overrides

  Scenario: uses default from eyaml when no config file
    When I run `eyaml version -v`
    Then the output should match /pkcs7_public_key\s+=\s+\(String\)\s+\..keys.public_key\.pkcs7\.pem/
    And the output should match /encrypt_method\s+=\s+\(String\)\s+pkcs7/
    And the output should match /plaintext_diagnostic_message\s+=\s+\(String\)\s+success/

  Scenario: uses default from configuration file
    Given my HOME is set to "fake_home"
    When I run `eyaml version -v`
    Then the output should match /pkcs7_public_key\s+=\s+\(String\)\s+overriden_pub_key\.pkcs7\.pem/
    And the output should match /encrypt_method\s+=\s+\(String\)\s+plaintext/
    And the output should match /plaintext_diagnostic_message\s+=\s+\(String\)\s+different/