class Setup

  def self.create_inputs
    Dir.mkdir("keys") unless Dir.exists?("keys")
    File.open("keys/private_key.pkcs7.pem", "w") {|private_key|
      private_key.puts '''
-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEA0kX0qkf4FOHXuFqlVmbgo+UDrJdneH8XnmWM+stAs0XpzEQq
ErelZUhEi2x5z16RAsEw3cjd2BG78WHz1lcu3NP25BM990YQDl6e9pvmeMNA+wCK
1bwD7fCWXrAKb7xIXPJVd0ivP82ZPe71CmkFtiFr14mqNWrEpP/d2eQ4PAaCimAE
bBKyRRHHJzU6X+hOnq8GRZBwKh6Ljl31JYE2DG3KQ+ydM+r411jY2sjSykOovbeR
b7FCyOPaLRgyNjiDIJSTRlWLVJbYj6KDSoUD2+R95Owb5Z1OUL9Yn/BRIv5RyDvf
Br42sp0KR7t3pWGiHEuRYZkGDU5jKB/8bK7DRwIDAQABAoIBAERJKZp/AsatTSP2
dAkqIbu37MiI5rZP97id2/m6NgnCI5oNbOhlMVZB8NiiYrCAUnFlkdwEll7L65AJ
MmmiKHrYby5EPXRnEWHJQrBtkpwXNKwO0gd1JoWIAx0+6DS/HXTp0e2J8jezKhfd
2UAHOS6bje0SLO9p+/Blk4NmRQjgsYk5nunl463+IkRGU8cna7GIOnvExrT6H3FD
UsL9hL1J/+f4cSmsJoNHtQfKV0OkmQhENpFFwVMunMJPDjGEbaliKqqX05ZnJ1Tu
kDKG+QL1wJbehDNNpiwTGo+Ei8EbP8LYsSkKtMl0zVED636AiuQ259oNDGXo2f+t
FG/1WOECgYEA8OTaHbWgUvtatGBsZ5PIw1VIRG7LZESF0HvlnkZOsCFg2NWrQ99U
sL2gLC0DVi80Yijjk0Kvrp5zU010uU4CuJHzT9ZN/nlPlwTteL6kr8XIh2sTpuE6
nfx4E309d366Hh5xy82AQ+jIeQZTAaPHlFmINrncS48WTfP6lxn5f3ECgYEA33WK
OtImhr4RYRmzcsfybW7PgxxpMSnrex/omZPWEHB14Fa2J6ny3KI9qBP1x6/h6Jfe
SonD4MZ48opiNljfWmgkJMSkqalpa3jDGc8vX1uWhn8NdAuFKAn5zLZC8mZ27VUI
LXLcChjyKPKVTwRnaNe0+rq7MgsqJJ4jo2atgjcCgYEAxPr9+IlKXlC3LQQj4NaR
tliITZ0jqAv4ODD35GKteYzxup2N/GQkxplo3na4YcMb3KB+5y4CppFe0GFn7xcB
VpfSFBizkkD0ehNHdBLAbBMZFNLUMQO/gOyv64/fsVTpMDPI7dRO7DjvpTcsrQyV
6JMFtWpp30dT/85fvSs6P6ECgYB2Sp2rN7ZHW/SNR3K0T15pSeC2EmMpMHzEyAZ0
zkrilvX/lUeGRbQX0hb7k91nIRdg7owxPy6fHdHG6zTEelV6YWjIwgQ9AD6bMult
Dz2PqEdN2ZJAnRyXLni7Qry73zwTtRDIJmaPPddrj8c0ditb19ypYhJYkopzqfdJ
t8AgDwKBgCyJLYU7pjhfJwOOVJjACa8ndtg0vIr+MGoe99/2hWm7QdX5PrOjDLOr
PeopgafeF1G6chhs4Qqh4LCmDA2NeX+zWcHkjLrKUIXMwb2YPuna7WToyCCeAm8+
K5Lnssm0P/UJI3CAef/4GXb30ZJYOhsU15/XwY5c8+f6IxRIpPEN
-----END RSA PRIVATE KEY-----
'''
    } unless File.exists?("keys/private_key.pkcs7.pem")

    File.open("keys/public_key.pkcs7.pem", "w") {|public_key|
      public_key.puts '''-----BEGIN CERTIFICATE-----
MIIC2TCCAcGgAwIBAgIBADANBgkqhkiG9w0BAQUFADAAMCAXDTEzMDgwMTE3MzU0
NVoYDzIwNjMwNzIwMTczNTQ1WjAAMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIB
CgKCAQEA0kX0qkf4FOHXuFqlVmbgo+UDrJdneH8XnmWM+stAs0XpzEQqErelZUhE
i2x5z16RAsEw3cjd2BG78WHz1lcu3NP25BM990YQDl6e9pvmeMNA+wCK1bwD7fCW
XrAKb7xIXPJVd0ivP82ZPe71CmkFtiFr14mqNWrEpP/d2eQ4PAaCimAEbBKyRRHH
JzU6X+hOnq8GRZBwKh6Ljl31JYE2DG3KQ+ydM+r411jY2sjSykOovbeRb7FCyOPa
LRgyNjiDIJSTRlWLVJbYj6KDSoUD2+R95Owb5Z1OUL9Yn/BRIv5RyDvfBr42sp0K
R7t3pWGiHEuRYZkGDU5jKB/8bK7DRwIDAQABo1wwWjAPBgNVHRMBAf8EBTADAQH/
MB0GA1UdDgQWBBR7PyZZ/WlaSjAf6GO2GLWXO5aINDAoBgNVHSMEITAfgBR7PyZZ
/WlaSjAf6GO2GLWXO5aINKEEpAIwAIIBADANBgkqhkiG9w0BAQUFAAOCAQEAspcX
VNb156OZqPxteosI2ijeewDH0sc3ogRDZnxbXqG6Pa44QzJNTUULaX3iEfmFw4TL
MW90NU4w4rzSIBGDGHTBOKZZBa2iTVRsYHuQ7Sd1A1MKc1dDFs9+Uj/6/vQ8Fkdx
v+iei5N/XFccgto4HiohXvEZhT4NjONIFR9UL+lWChp8OVb+ifOWCKF69iUUbMPC
uD7+UkrCYoVeVXkG1Rvw4E6BAbi75P6inX0lUnzNs4B0rvFynnV1Nsdb89cxI3pL
Q0yVE8/aIP9donqjXTu0h/GmOtVQH654NCQSs1dLD+K4+8mn591Nv4uLrCiNJzTM
zGRUV6zOPlUa3ye6Dg==
-----END CERTIFICATE-----
'''
    } unless File.exists?("keys/public_key.pkcs7.pem")

    File.open("with_password", "w") {|expect_script|
      expect_script.puts '''#!/usr/bin/expect -f
log_file password.output

spawn bash -c "[lindex $argv]"
expect "Enter password"
send "secretme\n"
expect eof
'''
      } unless File.exists?("with_password")

    File.chmod(0755, "with_password")

    File.open("test_input.txt", "w") {|input_file|
      input_file.puts '''The quick brown
fox jumped over
the lazy dog'''
    } unless File.exists?("test_input.txt")

    File.open("test_input.bin", "wb") {|input_file|
      input_file.puts ["89504e470d0a1a0a0000000d494844520000000a0000000a0802000000025058ea000000097048597300000b1300000b1301009a9c180000000774494d4507dd0801122a39c574bacb0000001d69545874436f6d6d656e7400000000004372656174656420776974682047494d50642e6507000000504944415418d3754f490e0021082bc4fff5ad7d211e341d4623a7862e94a82abc67184584b13dc39ca42e5d8abc39009256587a45f2003fda013d297b26c96e05b02b1ce7497ed5ee93ae167eb1ffed995e99262fb16f7a65000000004945"].pack('H*')
    } unless File.exists?("test_input.bin")
  end

end
