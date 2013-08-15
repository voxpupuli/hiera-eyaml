Feature: eyaml key generation

  In order to encrypt data with various encryption methods
  As a developer using hiera-eyaml
  I want to use the eyaml tool to generate keys and certs

  Scenario: create some pkcs7 keys
    When I run `eyaml -c --pkcs7-public-key keys/new_public_key.pem --pkcs7-private-key keys/new_private_key.pem`
    Then the output should match /Keys created OK/

  Scenario: create missing pkcs7 keys dir
    When I run `eyaml -c --pkcs7-public-key keys/missing/new_public_key.pem --pkcs7-private-key keys/missing/new_private_key.pem`
    Then the output should contain "Created key directory: keys/missing"

  Scenario: create some plaintext keys
    When I run `eyaml -n plaintext -c`
    Then the output should match /success/
