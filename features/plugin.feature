Feature: eyaml plugins

  In order to encrypt data with various encryption methods
  As a developer using hiera-eyaml
  I want to use the eyaml tool to encrypt data in various ways

  Scenario: encrypt using plaintext plugin
    When I run `eyaml -e -n plaintext -o string -s hello`
    Then the output should match /ENC\[PLAINTEXT,(.*?)\]$/

  Scenario: decrypt using plaintext plugin
    When I run `eyaml -d -n plaintext -s 'ENC[PLAINTEXT,aGVsbG8=]'`
    Then the output should match /^hello$/

  Scenario: decrypt using inferred plugin
    When I run `eyaml -d -s 'ENC[PLAINTEXT,aGVsbG8=]'`
    Then the output should match /^hello$/

  Scenario: decrypt using forced plaintext plugin
    When I run `eyaml -d -n plaintext -s 'ENC[aGVsbG8=]'`
    Then the output should match /^hello$/

  Scenario: decrypt using two plugins
    When I run `eyaml -d -s 'ENC[PLAINTEXT,cmVkIGxvcnJ5IA==]ENC[PKCS7,MIIBeQYJKoZIhvcNAQcDoIIBajCCAWYCAQAxggEhMIIBHQIBADAFMAACAQAwDQYJKoZIhvcNAQEBBQAEggEAaezXCbx6WspcsKsCkgr9thLEckRppDvQyFloAHqswDNXllHxTSJDYlyoi96YvO96wazffdWO05TMs7HmkqJHkRzoTLGTdXSMz2Mu14QkUDe0zZyB0hl8qTbTcHzrw3ybUEJZEZ45Eenmr5VKuoBina7XJdIAXW8Ps4L/Dj7zsXlUxuyjDWu2WUd2X4gxO3W1SGfntk4OQ41NKXYKPIZLAXWMjC4VFh20tKXFwYhCpAanTBRNWgLBX3Dwg+c/l35EW8OQLfdaOQ30R/DgcoSsAZJveH3xqBv7UOes7vONLSYXTek6yFJBll7EuGbA/Mdw4gxd1qtCBdf48IiPPR0peTA8BgkqhkiG9w0BBwEwHQYJYIZIAWUDBAEqBBCNWcGBqa8joAd0RMRzvx9VgBAf6PsvDZEa5cWdBaoTM/lP]'`
    Then the output should match /^red lorry blue lorry/

  Scenario: decrypt using two plugins with default plaintext
    When I run `eyaml -d -n plaintext -s 'ENC[cmVkIGxvcnJ5IA==]ENC[PKCS7,MIIBeQYJKoZIhvcNAQcDoIIBajCCAWYCAQAxggEhMIIBHQIBADAFMAACAQAwDQYJKoZIhvcNAQEBBQAEggEAaezXCbx6WspcsKsCkgr9thLEckRppDvQyFloAHqswDNXllHxTSJDYlyoi96YvO96wazffdWO05TMs7HmkqJHkRzoTLGTdXSMz2Mu14QkUDe0zZyB0hl8qTbTcHzrw3ybUEJZEZ45Eenmr5VKuoBina7XJdIAXW8Ps4L/Dj7zsXlUxuyjDWu2WUd2X4gxO3W1SGfntk4OQ41NKXYKPIZLAXWMjC4VFh20tKXFwYhCpAanTBRNWgLBX3Dwg+c/l35EW8OQLfdaOQ30R/DgcoSsAZJveH3xqBv7UOes7vONLSYXTek6yFJBll7EuGbA/Mdw4gxd1qtCBdf48IiPPR0peTA8BgkqhkiG9w0BBwEwHQYJYIZIAWUDBAEqBBCNWcGBqa8joAd0RMRzvx9VgBAf6PsvDZEa5cWdBaoTM/lP]'`
    Then the output should match /^red lorry blue lorry/

  Scenario: decrypt using two plugins with default pkcs7
    When I run `eyaml -d -n pkcs7 -s 'ENC[PLAINTEXT,cmVkIGxvcnJ5IA==]ENC[MIIBeQYJKoZIhvcNAQcDoIIBajCCAWYCAQAxggEhMIIBHQIBADAFMAACAQAwDQYJKoZIhvcNAQEBBQAEggEAaezXCbx6WspcsKsCkgr9thLEckRppDvQyFloAHqswDNXllHxTSJDYlyoi96YvO96wazffdWO05TMs7HmkqJHkRzoTLGTdXSMz2Mu14QkUDe0zZyB0hl8qTbTcHzrw3ybUEJZEZ45Eenmr5VKuoBina7XJdIAXW8Ps4L/Dj7zsXlUxuyjDWu2WUd2X4gxO3W1SGfntk4OQ41NKXYKPIZLAXWMjC4VFh20tKXFwYhCpAanTBRNWgLBX3Dwg+c/l35EW8OQLfdaOQ30R/DgcoSsAZJveH3xqBv7UOes7vONLSYXTek6yFJBll7EuGbA/Mdw4gxd1qtCBdf48IiPPR0peTA8BgkqhkiG9w0BBwEwHQYJYIZIAWUDBAEqBBCNWcGBqa8joAd0RMRzvx9VgBAf6PsvDZEa5cWdBaoTM/lP]'`
    Then the output should match /^red lorry blue lorry/


