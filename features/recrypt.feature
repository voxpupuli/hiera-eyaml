Feature: Recrypt
  In order to handle require changes in crypt
  I want to be able to re-encrypt all keys in file

  Scenario: Recrypt encrypted yaml
    Given I recrypt a file
    And I configure the keypair
    And I load a file called test_input.yaml
    And I recrypt it twice
    Then I should have 33 tokens
    Then the recrypted tokens should match
    Then the recrypted decrypted content should match
    Then the recrypted contents should differ
    Then the tokens at 1 should match
    Then the tokens at 5 should match
