Feature: eyaml encrypting is valid

  Scenario: encrypt and decrypt a binary file
    When I run `bash -c "eyaml encrypt -o string -f test_input.bin > test_output.txt"`
    When I run `bash -c "eyaml decrypt -f test_output.txt > test_output.bin"`
    When I run `file test_output.bin`
    Then the output should match /PNG image data/

  Scenario: encrypt and decrypt a simple file
    When I run `bash -c "eyaml encrypt -o string -f test_input.txt > test_output.txt"`
    When I run `eyaml decrypt -f test_output.txt`
    Then the output should match /fox jumped over/
  
  Scenario: encrypt and decrypt multiline yaml
    When I run `eyaml decrypt -f test_multiline_input.eyaml`
    Then the output should have a key of 'key' with 3 lines
    Then the output should have a key of 'theotherkey' with 3 lines

  Scenario: encrypt and decrypt windows multiline yaml
    When I run `eyaml decrypt -f test_multiline_win_input.eyaml`
    Then the output should have a key of 'key' with 3 lines
    Then the output should have a key of 'theotherkey' with 3 lines

