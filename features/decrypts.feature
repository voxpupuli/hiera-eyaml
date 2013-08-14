Feature: eyaml decrypting

  In order to decrypt data
  As a developer using hiera-eyaml
  I want to use the eyaml tool to decrypt data in various ways

  Scenario: decrypt a simple string
    When I run `eyaml -d -s 'ENC[PKCS7,MIIBiQYJKoZIhvcNAQcDoIIBejCCAXYCAQAxggEhMIIBHQIBADAFMAACAQAwDQYJKoZIhvcNAQEBBQAEggEAJsIbL+DE4b5mbT4ozzsGximhweXkJakBXRNqi/TOBV5RnMjlAhik2NQGyZdrg4fmQynyQvI7lKPos5bmqT6Ltk0XxfL0l1x8MIdVLDu7JG72a+5bbU7EK/PlhwaeJ0QpnA0M34koNykSmcvdVUoIDag71lqw4Hmk8JQuXmo95gP0sXHvlahgxR522Z8MTEitfimtZPnHJVMjQEnBHIwXLkEfqUHH3RciED3AkeU+En63Ou7Nq1SqoC4ln0oL1L2gRqsyEKWF/cigcZfAggh9rva6wlthh+Fj7yJy7ALVG/AXwrF1sJfTR31+RMbzPbgOHXES8P4yQvQnx6LNUSKAgDBMBgkqhkiG9w0BBwEwHQYJYIZIAWUDBAEqBBCSuNScp5k8F0RKt63fkoPrgCBYbnl44Wdv5mtaJmJcc0WIUcLTpixl1IY2uQ7IiI358w==]'`
    Then the output should match /^one flew over the cuckoos nest$/

  Scenario: decrypt a default encryption string
    When I run `eyaml -d -s 'ENC[MIIBiQYJKoZIhvcNAQcDoIIBejCCAXYCAQAxggEhMIIBHQIBADAFMAACAQAwDQYJKoZIhvcNAQEBBQAEggEAJsIbL+DE4b5mbT4ozzsGximhweXkJakBXRNqi/TOBV5RnMjlAhik2NQGyZdrg4fmQynyQvI7lKPos5bmqT6Ltk0XxfL0l1x8MIdVLDu7JG72a+5bbU7EK/PlhwaeJ0QpnA0M34koNykSmcvdVUoIDag71lqw4Hmk8JQuXmo95gP0sXHvlahgxR522Z8MTEitfimtZPnHJVMjQEnBHIwXLkEfqUHH3RciED3AkeU+En63Ou7Nq1SqoC4ln0oL1L2gRqsyEKWF/cigcZfAggh9rva6wlthh+Fj7yJy7ALVG/AXwrF1sJfTR31+RMbzPbgOHXES8P4yQvQnx6LNUSKAgDBMBgkqhkiG9w0BBwEwHQYJYIZIAWUDBAEqBBCSuNScp5k8F0RKt63fkoPrgCBYbnl44Wdv5mtaJmJcc0WIUcLTpixl1IY2uQ7IiI358w==]'`
    Then the output should match /^one flew over the cuckoos nest$/

  Scenario: decrypt an encrypted file
    When I run `eyaml -d -f test_input.encrypted.txt`
    Then the output should match /^danger will robinson$/

  Scenario: decrypt an eyaml file
    When I run `eyaml -d -y test_input.yaml`
    Then the output should match /encrypted_string: DEC::PKCS7\[planet of the apes\]\!/
    And the output should match /encrypted_block: >\n\s+DEC::PKCS7\[gangs of new york\]\!/
    And the output should match /\- DEC::PKCS7\[apocalypse now\]\!/
    And the output should match /\- DEC::PKCS7\[the count of monte cristo\]\!/
    And the output should match /\- array4/
    And the output should match /\- DEC::PKCS7\[dr strangelove\]\!/
    And the output should match /\- array5/
    And the output should match /\- >\n\s+DEC::PKCS7\[kramer vs kramer\]\!/
    And the output should match /\- >\n\s+DEC::PKCS7\[the manchurian candidate\]\!/
    And the output should match /\- >\n\s+tomorrow and tomorrow and\s*\n\s+tomorrow creeps/
    And the output should match /\- >\n\s+DEC::PKCS7\[much ado about nothing\]\!/
    And the output should match /\- >\n\s+when shall we three meet again\n\s+in thunder/
    And the output should match /\- DEC::PKCS7\[the english patient\]\!/
    And the output should match /\- >\n\s+DEC::PKCS7\[the pink panther\]\!/
    And the output should match /\- >\n\s+i wondered lonely\s*\n\s+as a cloud/
    And the output should match /\s+key5: DEC::PKCS7\[value5\]\!/
    And the output should match /\s+key6: DEC::PKCS7\[value6\]\!/

  Scenario: decrypt using STDIN
    When I run `./pipe_string.sh ENC[MIIBiQYJKoZIhvcNAQcDoIIBejCCAXYCAQAxggEhMIIBHQIBADAFMAACAQAwDQYJKoZIhvcNAQEBBQAEggEAJsIbL+DE4b5mbT4ozzsGximhweXkJakBXRNqi/TOBV5RnMjlAhik2NQGyZdrg4fmQynyQvI7lKPos5bmqT6Ltk0XxfL0l1x8MIdVLDu7JG72a+5bbU7EK/PlhwaeJ0QpnA0M34koNykSmcvdVUoIDag71lqw4Hmk8JQuXmo95gP0sXHvlahgxR522Z8MTEitfimtZPnHJVMjQEnBHIwXLkEfqUHH3RciED3AkeU+En63Ou7Nq1SqoC4ln0oL1L2gRqsyEKWF/cigcZfAggh9rva6wlthh+Fj7yJy7ALVG/AXwrF1sJfTR31+RMbzPbgOHXES8P4yQvQnx6LNUSKAgDBMBgkqhkiG9w0BBwEwHQYJYIZIAWUDBAEqBBCSuNScp5k8F0RKt63fkoPrgCBYbnl44Wdv5mtaJmJcc0WIUcLTpixl1IY2uQ7IiI358w==] eyaml -d --stdin`
    Then the output should match /^one flew over the cuckoos nest$/



