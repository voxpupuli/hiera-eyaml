Feature: eyaml key generation

  In order to encrypt data with various encryption methods
  As a developer using hiera-eyaml
  I want to use the eyaml tool to generate keys and certs

  Scenario: create some pkcs7 keys
    When I run `eyaml createkeys --pkcs7-public-key keys/new_public_key.pem --pkcs7-private-key keys/new_private_key.pem`
    Then the output should match /Keys created OK/

  Scenario: decline to overwrite some pkcs7 keys
    When I run `touch keys/new_private_key.pem`
    And I run `eyaml createkeys --pkcs7-public-key keys/new_public_key.pem --pkcs7-private-key keys/new_private_key.pem` interactively
    And I wait for stderr to contain "Are you sure you want to overwrite \"keys/new_private_key.pem\"? (y/N): "
    And I type ""
    Then the output should match /User aborted/

  Scenario: overwrite some pkcs7 keys
    When I run `touch keys/new_public_key.pem keys/new_private_key.pem`
    And I run `eyaml createkeys --pkcs7-public-key keys/new_public_key.pem --pkcs7-private-key keys/new_private_key.pem` interactively
    And I wait for stderr to contain "Are you sure you want to overwrite \"keys/new_private_key.pem\"? (y/N): "
    And I type "y"
    And I wait for stderr to contain "Are you sure you want to overwrite \"keys/new_public_key.pem\"? (y/N): "
    And I type "y"
    Then the output should match /Keys created OK/

  Scenario: create missing pkcs7 keys dir
    When I run `eyaml createkeys --pkcs7-public-key keys/missing/new_public_key.pem --pkcs7-private-key keys/missing/new_private_key.pem`
    Then the output should contain "Created key directory: keys/missing"

  Scenario: create some plaintext keys
    When I run `eyaml createkeys -n plaintext`
    Then the output should match /success/

  Scenario: pkcs7 keys created by createkeys have a non-empty subject and issuer
    When I successfully run `eyaml createkeys --pkcs7-public-key keys/subject_public_key.pem --pkcs7-private-key keys/subject_private_key.pem`
    Then the output should match /Keys created OK/
    When I successfully run `openssl x509 -in keys/subject_public_key.pem -noout -subject -issuer`
    Then the output should match /^subject=\s*CN\s*=\s*eyaml$/
    And the output should match /^issuer=\s*CN\s*=\s*eyaml$/

  Scenario: keys created by createkeys can encrypt and decrypt a value
    When I successfully run `eyaml createkeys --pkcs7-public-key keys/roundtrip_public_key.pem --pkcs7-private-key keys/roundtrip_private_key.pem`
    Then the output should match /Keys created OK/
    When I successfully run `bash -c "eyaml encrypt -o string -s roundtrip_secret --pkcs7-public-key keys/roundtrip_public_key.pem --pkcs7-private-key keys/roundtrip_private_key.pem > roundtrip_output.txt"`
    And I successfully run `eyaml decrypt -f roundtrip_output.txt --pkcs7-public-key keys/roundtrip_public_key.pem --pkcs7-private-key keys/roundtrip_private_key.pem`
    Then the output should match /roundtrip_secret/
