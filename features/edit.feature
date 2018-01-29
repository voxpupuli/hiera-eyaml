Feature: eyaml editing

  In order to edit encrypted data
  As a developer using hiera-eyaml
  I want to use the eyaml tool to edit data in various ways

  Scenario: decrypt an eyaml file
    Given my EDITOR is set to "/bin/cat"
    When I run `bash -c 'cp test_input.yaml test_input.eyaml'`
    When I run `eyaml edit test_input.eyaml`
    Then the output should match /encrypted_string: DEC\(\d+\)::PKCS7\[planet of the apes\]\!/
    And the output should match /encrypted_default_encryption_string: DEC\(\d+\)::PKCS7\[planet of the apes\]\!/
    And the output should match /encrypted_block: >\n\s+DEC\(\d+\)::PKCS7\[gangs of new york\]\!/
    And the output should match /encrypted_tabbed_block: >\n\s+DEC\(\d+\)::PKCS7\[gangs of new york\]\!/
    And the output should match /encrypted_default_encryption_block: >\n\s+DEC\(\d\)::PKCS7\[gangs of new york\]\!/
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
    And the output should match /multi_encryption: DEC\(\d+\)::PLAINTEXT\[jammy\]\! DEC\(\d+\)::PKCS7\[dodger\]!/

  Scenario: decrypting a eyaml file should create a temporary file
    Given my EDITOR is set to "/usr/bin/env true"
    When I run `bash -c 'cp test_input.yaml test_input.eyaml'`
    When I run `eyaml edit -v test_input.eyaml`
    Then the stderr should contain "Wrote temporary file"

  Scenario: decrypting a eyaml file should add a preamble
    Given my EDITOR is set to "/bin/cat"
    When I run `bash -c 'cp test_input.yaml test_input.eyaml'`
    When I run `eyaml edit test_input.eyaml`
    Then the output should match /#| This is eyaml edit mode/

  Scenario: decrypting a eyaml file with --no-preamble should NOT add a preamble
    Given my EDITOR is set to "/bin/cat"
    When I run `bash -c 'cp test_input.yaml test_input.eyaml'`
    When I run `eyaml edit --no-preamble test_input.eyaml`
    Then the output should not match /#| This is eyaml edit mode/

  Scenario: editing a eyaml file should not leave the preamble
    Given my EDITOR is set to "./convert_decrypted_values_to_uppercase.sh"
    When I run `bash -c 'cp test_input.yaml test_input.eyaml'`
    When I run `eyaml edit test_input.eyaml`
    Then the file "test_input.eyaml" should not match /#| This is eyaml edit mode/

  Scenario: editing a non-existant eyaml file should give you a blank file
    Given my EDITOR is set to "/bin/cat"
    When I run `bash -c 'rm non-existant-file.eyaml'`
    When I run `eyaml edit --no-preamble non-existant-file.eyaml`
    Then the output should match /^---/

  Scenario: editing a non-existant eyaml file should save a new file
    Given my EDITOR is set to "./append.sh test_new_values.yaml"
    When I run `bash -c 'rm non-existant-file.eyaml'`
    When I run `eyaml edit non-existant-file.eyaml`
    When I run `eyaml decrypt -e non-existant-file.eyaml`
    Then the output should not match /#| This is eyaml edit mode/
    And the output should match /new_key1: DEC::PKCS7\[new value one\]\!/
    And the output should match /new_key2: DEC::PKCS7\[new value two\]\!/

  Scenario: decrypt and reencrypt an eyaml file
    Given my EDITOR is set to "./convert_decrypted_values_to_uppercase.sh"
    When I run `bash -c 'cp test_input.yaml test_input.eyaml'`
    When I run `eyaml edit test_input.eyaml`
    When I run `eyaml decrypt -e test_input.eyaml`
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

  Scenario: decrypt and reencrypt an eyaml file with multiple new values
    Given my EDITOR is set to "./append.sh test_new_values.yaml"
    When I run `bash -c 'cp test_input.yaml test_input.eyaml'`
    When I run `eyaml edit test_input.eyaml`
    When I run `eyaml decrypt -e test_input.eyaml`
    Then the output should match /encrypted_string: DEC::PKCS7\[planet of the apes\]\!/
    And the output should match /new_key1: DEC::PKCS7\[new value one\]\!/
    And the output should match /new_key2: DEC::PKCS7\[new value two\]\!/
    And the output should match /multi_encryption: DEC::PLAINTEXT\[jammy\]\! DEC::PKCS7\[dodger\]!/

  Scenario: not editing a file should result in an untouched file
    Given my EDITOR is set to "/usr/bin/env true"
    When I run `bash -c 'cp test_edit.yaml test_edit.eyaml'`
    When I run `eyaml edit test_edit.eyaml`
    When I run `bash -c 'diff test_edit.yaml test_edit.eyaml'`
    Then the exit status should be 0

  Scenario: not editing a file should result in a no changes detected message
    Given my EDITOR is set to "/usr/bin/env true"
    When I run `bash -c 'cp test_edit.yaml test_edit.eyaml'`
    When I run `eyaml edit test_edit.eyaml`
    Then the stderr should contain "No changes detected"

  Scenario: not modifying the plaintext should result in no encryption
    Given my EDITOR is set to "sed -i.bak s/simple_array/test_array/g"
    When I run `bash -c 'cp test_input.yaml test_input.eyaml'`
    When I run `eyaml edit -t test_input.eyaml`
    Then the output should not contain "PKCS7 encrypt"

  Scenario: modifying the plaintext should result in an encryption
    Given my EDITOR is set to "sed -i.bak s/value6/value7/g"
    When I run `bash -c 'cp test_input.yaml test_input.eyaml'`
    When I run `eyaml edit -t test_input.eyaml`
    Then the output should contain "PKCS7 encrypt"

  Scenario: editing but not modifying a eyaml file with --no-preamble should be detected
    Given my EDITOR is set to "/usr/bin/env true"
    When I run `bash -c 'cp test_edit.yaml test_edit.eyaml'`
    When I run `eyaml edit --no-preamble test_edit.eyaml`
    Then the stderr should contain "No changes detected"

  Scenario: encrypt-only mode should not decrypt input
    Given my EDITOR is set to "/bin/cat"
    When I run `bash -c 'cp test_input.yaml test_input.eyaml'`
    When I run `eyaml edit --encrypt-only test_input.eyaml`
    Then the output should not match /DEC\(\d+\)/
    And the output should match /encrypted_string: ENC\[PKCS7,[^\]]+\]/

  Scenario: encrypt-only mode should encrypt new values
    Given my EDITOR is set to "./append.sh test_new_values.yaml"
    When I run `bash -c 'cp test_edit.yaml test_edit.eyaml'`
    When I run `eyaml edit -y test_edit.eyaml`
    When I run `eyaml decrypt -e test_edit.eyaml`
    Then the output should match /new_key1: DEC::PKCS7\[new value one\]\!/
    And the output should match /new_key2: DEC::PKCS7\[new value two\]\!/

  Scenario: encrypt-only mode should not modify existing values
    Given my EDITOR is set to "./append.sh test_new_values.yaml"
    When I run `bash -c 'cp test_edit.yaml test_edit.eyaml'`
    When I run `eyaml edit -y test_edit.eyaml`
    When I run `cat test_edit.eyaml`
    Then the output should contain "encrypted_string: ENC[PKCS7,MIIBiQYJKoZIhvcNAQcDoIIBejCCAXYCAQAxggEhMIIBHQIBADAFMAACAQAwDQYJKoZIhvcNAQEBBQAEggEAgld+rftjW8WmMwTJLX/3Kk9hQv9ZUufsieijxhnCo3gtR/6xaKdMC4wpYM9Eck7FFdmjz2XnJK9o5rlvjW5ZBH3u2A3tphs6cgy7HzsfrsJvw1Mc+CLSNL35MVi/YvNCxezn+rXn28NW8NntByoLTzZnd6iGxSBk4S7Z7XwvdQWuUjXy0muEeAUYtS/eppNZYdyeMpzE9oHmfMM+zwdOYzc/nfwvnoLHGP+sv6KmnzCyNtqyrdvCIn+m+ljPWpGvj410Q52Xili1Scgi+ALJf4xiEnD5c5YjEkYY8uUe4etCDYZ/aXp9RGvZiHD8Le6jz34fcWbLZlQacCfgcyY8AzBMBgkqhkiG9w0BBwEwHQYJYIZIAWUDBAEqBBD4CRz8QLvbtgRx/NTxEnpfgCBLQD1ei8KAcd0LTT7sezZPt6LQnLxPuwx5StflI5xOgA==]"

  Scenario: encrypt-only mode should succeed even if keyfile is unreadable
    Given my EDITOR is set to "/bin/cat"
    When I run `bash -c 'cp test_edit.yaml test_edit.eyaml'`
    When I run `eyaml edit -y --pkcs7-private-key=not_a_keyfile test_edit.eyaml`
    Then the exit status should be 0
    And the stderr should not contain "No such file or directory"
    And the output should not match /DEC\(\d+\)/
    And the output should match /encrypted_string: ENC\[PKCS7,/

  Scenario: EDITOR has a space in it that isn't quoted or escaped
    Given my EDITOR is set to "./path/spaced editor.sh"
    When I run `bash -c 'cp test_input.yaml test_input.eyaml'`
    When I run `eyaml edit test_input.eyaml`
    Then the stderr should contain "No changes detected"

  Scenario: EDITOR has a space in it that is escaped but not isn't quoted
    Given my EDITOR is set to "./path/spaced\ editor.sh"
    When I run `bash -c 'cp test_input.yaml test_input.eyaml'`
    When I run `eyaml edit test_input.eyaml`
    Then the stderr should contain "No changes detected"

  Scenario: EDITOR has a space in it that is quoted
    Given my EDITOR is set to ""./path/spaced editor.sh""
    When I run `bash -c 'cp test_input.yaml test_input.eyaml'`
    When I run `eyaml edit test_input.eyaml`
    Then the stderr should contain "No changes detected"

  Scenario: EDITOR is an executable on PATH
    Given my EDITOR is set to "editor.sh"
    Given my PATH contains "./path"
    When I run `bash -c 'cp test_input.yaml test_input.eyaml'`
    When I run `eyaml edit test_input.eyaml`
    Then the stderr should contain "No changes detected"

  Scenario: EDITOR is an executable on PATH and contains arguments
    Given my EDITOR is set to "editor.sh -c"
    Given my PATH contains "./path"
    When I run `bash -c 'cp test_input.yaml test_input.eyaml'`
    When I run `eyaml edit test_input.eyaml`
    Then the output should match /editor\.sh" -c/
    Then the stderr should contain "No changes detected"

  Scenario: EDITOR is an executable on PATH and has a space in it that isn't quoted or escaped
    Given my EDITOR is set to "spaced editor.sh"
    Given my PATH contains "./path"
    When I run `bash -c 'cp test_input.yaml test_input.eyaml'`
    When I run `eyaml edit test_input.eyaml`
    Then the stderr should contain "No changes detected"

  Scenario: EDITOR is an executable on PATH and has a space in it that is escaped but not quoted
    Given my EDITOR is set to "spaced\ editor.sh"
    Given my PATH contains "./path"
    When I run `bash -c 'cp test_input.yaml test_input.eyaml'`
    When I run `eyaml edit test_input.eyaml`
    Then the stderr should contain "No changes detected"

  Scenario: EDITOR is an executable on PATH and has a space in it that is quoted
    Given my EDITOR is set to ""spaced editor.sh""
    Given my PATH contains "./path"
    When I run `bash -c 'cp test_input.yaml test_input.eyaml'`
    When I run `eyaml edit test_input.eyaml`
    Then the stderr should contain "No changes detected"

  Scenario: EDITOR is an executable on PATH and has a space in it and contains arguments
    Given my EDITOR is set to "spaced editor.sh -c"
    Given my PATH contains "./path"
    When I run `bash -c 'cp test_input.yaml test_input.eyaml'`
    When I run `eyaml edit test_input.eyaml`
    Then the output should match /spaced editor\.sh" -c/
    Then the stderr should contain "No changes detected"

  Scenario: EDITOR is invalid
    Given my EDITOR is set to "does_not_exist.sh"
    When I run `bash -c 'cp test_input.yaml test_input.eyaml'`
    When I run `eyaml edit test_input.eyaml`
    Then the stderr should contain "Editor did not exit successfully"
    Then the stderr should not contain "Wrote temporary file"
