Feature: eyaml encrypting

  In order to encrypt data
  As a developer using hiera-eyaml
  I want to use the eyaml tool to ecnrypt data in various ways

  Scenario: encrypt a simple string
    When I run `eyaml -e -o string -s some_string`
    Then the output should match /ENC\[PKCS7,(.*?)\]$/

  Scenario: encrypt a simple file
    When I run `eyaml -e -o string -f test_input.txt`
    Then the output should match /ENC\[PKCS7,(.*?)\]$/

  Scenario: encrypt a binary file
    When I run `eyaml -e -o string -f test_input.bin`
    Then the output should match /ENC\[PKCS7,(.*?)\]$/

  Scenario: encrypt a password
    When I run `./with_password eyaml -e -o string -p`
    Then the file "password.output" should match /ENC\[PKCS7,(.*?)\]/
