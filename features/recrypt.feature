Feature: Recrypt
  In order to handle require changes in crypt
  I want to be able to re-encrypt all keys in file

  Scenario: Recrypt encrypted yaml
    Given I recrypt a file
    And I configure the keypair
    And I load a file called test_input.yaml
    And I recrypt it twice
    Then I should have 35 tokens
    Then the recrypted tokens should match
    Then the recrypted decrypted content should match
    Then the recrypted contents should differ
    Then the tokens at 1 should match
    Then the tokens at 5 should match

  Scenario: Recrypt encrypted yaml using the eyaml tool
    When I run `bash -c 'cp test_input.yaml test_input.eyaml'`
    And I run `eyaml recrypt test_input.yaml`
    When I run `diff -q test_input.yaml test_input.eyaml`
    Then the exit status should be 1
    And I run `eyaml decrypt -e test_input.eyaml`
    Then the output should match /encrypted_string: DEC::PKCS7\[planet of the apes\]\!/
