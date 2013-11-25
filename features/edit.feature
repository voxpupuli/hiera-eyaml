Feature: eyaml editing

  In order to edit encrypted data
  As a developer using hiera-eyaml
  I want to use the eyaml tool to edit data in various ways

  Scenario: decrypt an eyaml file
    Given my EDITOR is set to "/bin/cat"
    When I run `bash -c 'cp test_input.yaml test_input.eyaml'`
    When I run `eyaml edit test_input.eyaml`
    Then the output should match /encrypted_string: DEC\(1\)::PKCS7\[planet of the apes\]\!/
    And the output should match /encrypted_default_encryption_string: DEC\(3\)::PKCS7\[planet of the apes\]\!/
    And the output should match /encrypted_block: >\n\s+DEC\(5\)::PKCS7\[gangs of new york\]\!/
    And the output should match /encrypted_default_encryption_block: >\n\s+DEC\(7\)::PKCS7\[gangs of new york\]\!/
    And the output should match /\- DEC\(\d+\)::PKCS7\[apocalypse now\]\!/
    And the output should match /\- DEC\(\d+\)::PKCS7\[the count of monte cristo\]\!/
    And the output should match /\- array4/
    And the output should match /\- DEC\(\d+\)::PKCS7\[dr strangelove\]\!/
    And the output should match /\- array5/
    And the output should match /\- >\n\s+DEC\(\d+\)::PKCS7\[kramer vs kramer\]\!/
    And the output should match /\- >\n\s+DEC\(\d+\)::PKCS7\[the manchurian candidate\]\!/
    And the output should match /\- >\n\s+tomorrow and tomorrow and\s*\n\s+tomorrow creeps/
    And the output should match /\- >\n\s+DEC\(\d+\)::PKCS7\[much ado about nothing\]\!/
    And the output should match /\- >\n\s+when shall we three meet again\n\s+in thunder/
    And the output should match /\- DEC\(\d+\)::PKCS7\[the english patient\]\!/
    And the output should match /\- >\n\s+DEC\(\d+\)::PKCS7\[the pink panther\]\!/
    And the output should match /\- >\n\s+i wondered lonely\s*\n\s+as a cloud/
    And the output should match /\s+key5: DEC\(\d+\)::PKCS7\[value5\]\!/
    And the output should match /\s+key6: DEC\(\d+\)::PKCS7\[value6\]\!/
    And the output should match /multi_encryption: DEC\(29\)::PLAINTEXT\[jammy\]\! DEC\(\d+\)::PKCS7\[dodger\]!/

  Scenario: decrypt and reencrypt an eyaml file
    Given my EDITOR is set to "./convert_decrypted_values_to_uppercase.sh"
    When I run `bash -c 'cp test_input.yaml test_input.eyaml'`
    When I run `eyaml edit test_input.eyaml`
    When I run `eyaml decrypt -y test_input.eyaml`
    Then the output should match /encrypted_string: DEC::PKCS7\[PLANET OF THE APES\]\!/
    And the output should match /encrypted_block: >\n\s+DEC::PKCS7\[GANGS OF NEW YORK\]\!/
    And the output should match /\- DEC::PKCS7\[APOCALYPSE NOW\]\!/
    And the output should match /\- DEC::PKCS7\[THE COUNT OF MONTE CRISTO\]\!/
    And the output should match /\- array4/
    And the output should match /\- DEC::PKCS7\[DR STRANGELOVE\]\!/
    And the output should match /\- array5/
    And the output should match /\- >\n\s+DEC::PKCS7\[KRAMER VS KRAMER\]\!/
    And the output should match /\- >\n\s+DEC::PKCS7\[THE MANCHURIAN CANDIDATE\]\!/
    And the output should match /\- >\n\s+tomorrow and tomorrow and\s*\n\s+tomorrow creeps/
    And the output should match /\- >\n\s+DEC::PKCS7\[MUCH ADO ABOUT NOTHING\]\!/
    And the output should match /\- >\n\s+when shall we three meet again\n\s+in thunder/
    And the output should match /\- DEC::PKCS7\[THE ENGLISH PATIENT\]\!/
    And the output should match /\- >\n\s+DEC::PKCS7\[THE PINK PANTHER\]\!/
    And the output should match /\- >\n\s+i wondered lonely\s*\n\s+as a cloud/
    And the output should match /\s+key5: DEC::PKCS7\[VALUE5\]\!/
    And the output should match /\s+key6: DEC::PKCS7\[VALUE6\]\!/
    And the output should match /multi_encryption: DEC::PLAINTEXT\[JAMMY\]\! DEC::PKCS7\[DODGER\]\!/
