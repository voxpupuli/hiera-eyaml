Feature: eyaml encrypting

  In order to encrypt data
  As a developer using hiera-eyaml
  I want to use the eyaml tool to encrypt data in various ways

  Scenario: encrypt a simple string
    When I run `eyaml encrypt -o string -s some_string`
    Then the output should match /\AENC\[PKCS7,(.*?)\]\z/

  Scenario: encrypt a simple file
    When I run `eyaml encrypt -o string -f test_input.txt`
    Then the output should match /\AENC\[PKCS7,(.*?)\]\z/

  Scenario: encrypt a eyaml file
    When I run `eyaml encrypt --eyaml test_plain.yaml`
    Then the output should match /key: ENC\[PKCS7,(.*?)\]$/

  Scenario: encrypt a binary file
    When I run `eyaml encrypt -o string -f test_input.bin`
    Then the output should match /\AENC\[PKCS7,(.*?)\]\z/

  Scenario: encrypt a password
    When I run `eyaml encrypt -o string -p` interactively
    And I wait for stderr to contain "Enter password: "
    And I type "secretme"
    Then the stdout should match /\AENC\[PKCS7,(.*?)\]\z/

  Scenario: encrypt using STDIN
    When I run `eyaml encrypt -o string --stdin` interactively
    And I type "encrypt_me"
    And I close the stdin stream
    Then the output should match /\AENC\[PKCS7,(.*?)\]\z/

  Scenario: encrypt as string with a label
    When I run `eyaml encrypt -o string -s secret_thing -l db-password`
    Then the output should match /\Adb-password: ENC\[PKCS7,(.*?)\]\z/

  Scenario: encrypt as block with a label
    When I run `eyaml encrypt -o block -s secret_thing -l db-password`
    Then the output should match /db-password: \>\s*ENC\[PKCS7,(.*?)\]$/
