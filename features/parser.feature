Feature: Parser
  In order to more easily parse EYAML ENC blocks
  As a frustrated developer trying to enhance the edit mode
  I want to be given a set of tokens from EYAML input and our regex expressions

  Scenario: Parse with no regexs
    Given I make a parser instance with no regexs
    And I load a file called test_input.yaml
    When I parse the content
    Then I should have 1 token
    Then token 1 should be a NonMatchToken

  Scenario: Parse encrypted yaml
    Given I make a parser instance with the ENC regexs
    And I configure the keypair
    And I load a file called test_input.yaml
    When I parse the content
    Then I should have 35 tokens
    Then token 1 should be a NonMatchToken
    Then token 2 should be a EncToken
    Then token 2 should start with "ENC[PKCS7,MIIBiQYJKoZIhvcNAQ"
    Then token 2 should decrypt to start with "planet of the apes"
    Then token 2 should decrypt to a string with UTF-8 encodings

  Scenario: Parse encrypted yaml with keypair as envvars
    Given I make a parser instance with the ENC regexs
    And I configure the keypair using envvars
    And I load the keypair into envvars
    And I load a file called test_input.yaml
    When I parse the content
    Then I should have 35 tokens
    Then token 1 should be a NonMatchToken
    Then token 2 should be a EncToken
    Then token 2 should start with "ENC[PKCS7,MIIBiQYJKoZIhvcNAQ"
    Then token 2 should decrypt to start with "planet of the apes"
    Then token 2 should decrypt to a string with UTF-8 encodings

  Scenario: Parse decrypted yaml
    Given I make a parser instance with the DEC regexs
    And I configure the keypair using envvars
    And I load the keypair into envvars
    And I load a file called test_plain.yaml
    When I parse the content
    Then I should have 2 tokens
    Then token 1 should be a NonMatchToken
    Then token 2 should be a EncToken

  Scenario: Parse decrypted yaml with index
    Given I make a parser instance with the DEC regexs
    And I configure the keypair using envvars
    And I load the keypair into envvars
    And I load a file called test_plain_with_index.yaml
    When I parse the content
    Then I should have 5 tokens
    Then token 1 should be a NonMatchToken
    Then token 2 should be a EncToken
    Then token 2 id should be 23
    Then token 3 should be a NonMatchToken
    Then token 4 should be a EncToken
    Then token 4 id should be 24

  Scenario: Output indexed decryption tokens
    Given I make a parser instance with the ENC regexs
    And I configure the keypair using envvars
    And I load the keypair into envvars
    And I load a file called test_input.yaml
    When I parse the content
    And map it to index decrypted values
    Then decryption 1 should be "DEC(1)::PKCS7[planet of the apes]!"
    Then decryption 13 should be "DEC(13)::PKCS7[the count of monte cristo]!"
