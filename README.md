# Hiera eyaml


[![License](https://img.shields.io/github/license/voxpupuli/hiera-eyaml.svg)](https://github.com/voxpupuli/hiera-eyaml/blob/master/LICENSE.txt)
[![Test](https://github.com/voxpupuli/hiera-eyaml/actions/workflows/test.yml/badge.svg)](https://github.com/voxpupuli/hiera-eyaml/actions/workflows/test.yml)
[![codecov](https://codecov.io/gh/voxpupuli/hiera-eyaml/branch/master/graph/badge.svg)](https://codecov.io/gh/voxpupuli/hiera-eyaml)
[![Release](https://github.com/voxpupuli/hiera-eyaml/actions/workflows/release.yml/badge.svg)](https://github.com/voxpupuli/hiera-eyaml/actions/workflows/release.yml)
[![RubyGem Version](https://img.shields.io/gem/v/hiera-eyaml.svg)](https://rubygems.org/gems/hiera-eyaml)
[![RubyGem Downloads](https://img.shields.io/gem/dt/hiera-eyaml.svg)](https://rubygems.org/gems/hiera-eyaml)

hiera-eyaml is a backend for Hiera that provides per-value encryption of sensitive data within yaml files
to be used by Puppet.

-------------------------
:new: **hiera-eyaml is now part of Vox Pupuli**

hiera-eyaml has a new home https://github.com/voxpupuli/hiera-eyaml.

Hopefully this will mean more frequent feature updates and bug fixes!

Advantages over hiera-gpg
-------------------------

A few people found that [hiera-gpg](https://github.com/crayfishx/hiera-gpg) just wasn't cutting it for all use cases,
one of the best expressed frustrations was
[written back in June 2013](http://slashdevslashrandom.wordpress.com/2013/06/03/my-griefs-with-hiera-gpg/). So
[Tom created an initial version](http://themettlemonkey.wordpress.com/2013/07/15/hiera-eyaml-per-value-encrypted-backend-for-hiera-and-puppet/)
and this was refined into an elegant solution over the following months.

Unlike `hiera-gpg`, `hiera-eyaml`:

 - only encrypts the values (which allows files to be swiftly reviewed without decryption)
 - encrypts the value of each key individually (this means that `git diff` is meaningful)
 - includes a command line tool for encrypting, decrypting, editing and rotating keys (makes it almost as
   easy as using clear text files)
 - uses basic asymmetric encryption (PKCS#7) by default (doesn't require any native libraries that need to
   be compiled & allows users without the private key to encrypt values that the puppet master can decrypt)
 - has a pluggable encryption framework (e.g. GPG encryption ([hiera-eyaml-gpg](https://github.com/voxpupuli/hiera-eyaml-gpg)) can be used
   if you have the need for multiple keys and easier key rotation)

The Hiera eyaml backend uses yaml formatted files with the .eyaml extension. The encrypted strings are prefixed with the encryption
method, wrapped with ENC[] and placed in an eyaml file. You can mix your plain values in as well or separate them into different files.
Encrypted values can occur within arrays, hashes, nested arrays and nested hashes.

For instance:

```yaml
---
plain-property: You can see me

encrypted-property: >
    ENC[PKCS7,Y22exl+OvjDe+drmik2XEeD3VQtl1uZJXFFF2NnrMXDWx0csyqLB/2NOWefv
    NBTZfOlPvMlAesyr4bUY4I5XeVbVk38XKxeriH69EFAD4CahIZlC8lkE/uDh
    jJGQfh052eonkungHIcuGKY/5sEbbZl/qufjAtp/ufor15VBJtsXt17tXP4y
    l5ZP119Fwq8xiREGOL0lVvFYJz2hZc1ppPCNG5lwuLnTekXN/OazNYpf4CMd
    /HjZFXwcXRtTlzewJLc+/gox2IfByQRhsI/AgogRfYQKocZgFb/DOZoXR7wm
    IZGeunzwhqfmEtGiqpvJJQ5wVRdzJVpTnANBA5qxeA==]
```

To edit this you can use the command `eyaml edit important.eyaml` which will decrypt the file, fire up an editor with
the decrypted values and re-encrypt any edited values when you exit the editor. This tool makes editing your encrypted
files as simple as clear text files.


Setup
-----

### Installing hiera-eyaml

#### RubyGems

    $ gem install hiera-eyaml

#### Apt (Ubuntu 18.04+)

    $ sudo apt install hiera-eyaml

### Installing hiera-eyaml for [puppetserver](https://github.com/puppetlabs/puppetserver)

All commands need to be executed as root. Puppet Enterprise vendors hiera-eyaml
already, so you don't need to install it there.

```sh
puppetserver gem install hiera-eyaml
```

or via puppet:

```sh
puppet resource package hiera-eyaml ensure=installed provider=puppetserver_gem
```

or via Puppet DSL:

```puppet
package { 'hiera-eyaml':
  ensure   => 'installed',
  provider => 'puppetserver_gem',
}
```

### Generate keys

The first step is to create a pair of keys:

    $ eyaml createkeys

This creates a public and private key with default names in the default location. (./keys)

#### Storing the keys securely when using Puppet

Since the point of using this module is to securely store sensitive information, it's important to store these keys securely.
If using Hiera with Puppet, Your puppetmaster will need to access these keys to perform decryption when the puppet agent runs on a remote node.
So for this reason, a suggested location might be to store them in `/etc/puppetlabs/puppet/eyaml` or `/var/lib/puppet/keys` depending on your setup.

The permissions for this folder should allow the puppet user (normally 'puppet') execute access to the keys directory, read only access to the keys themselves and restrict everyone else:

    $ chown -R puppet:puppet /etc/puppetlabs/puppet/eyaml
    $ chmod -R 0500 /etc/puppetlabs/puppet/eyaml
    $ chmod 0400 /etc/puppetlabs/puppet/eyaml/*.pem
    $ ls -lha /etc/puppetlabs/puppet/eyaml
    -r-------- 1 puppet puppet 1.7K Sep 24 16:24 private_key.pkcs7.pem
    -r-------- 1 puppet puppet 1.1K Sep 24 16:24 public_key.pkcs7.pem

You may also load the keypair into an environment variable and use the `pkcs7_private_key_env_var` and `pkcs7_public_key_env_var` options to specify the environment variable names to avoid writing the secret key to disk.


Basic usage
-----------

### Encryption

To encrypt something, you only need the public_key, so distribute that to people creating hiera properties

    $ eyaml encrypt -f filename            # Encrypt a file
    $ eyaml encrypt -s 'hello there'       # Encrypt a string
    $ eyaml encrypt -p                     # Encrypt a password (prompt for it)

Use the -l parameter to pass in a label for the encrypted value,

    $ eyaml encrypt -l 'some_easy_to_use_label' -s 'yourSecretString'


### Decryption

To decrypt something, you need the public_key and the private_key.

To test decryption you can also use the eyaml tool if you have both keys

    $ eyaml decrypt -f filename               # Decrypt a file
    $ eyaml decrypt -s 'ENC[PKCS7,.....]'     # Decrypt a string

### Editing files with a mixture of eyaml-encrypted and plain-text content

This is, perhaps, the most common use of eyaml where you have created a few
eyaml files, with a mixture of encrypted and non-encrypted properties, you can
edit the encrypted values in place, using the special edit mode of the eyaml
utility. Edit mode opens a decrypted copy of the eyaml file in your `$EDITOR`
and will encrypt and modified values when you exit the editor.

    $ eyaml edit filename.eyaml         # Edit an eyaml file in place

When editing eyaml files, you will see that the unencrypted plaintext is marked to allow the eyaml tool to
identify each encrypted block, along with the encryption method. This is used to make sure that the block
is encrypted again only if the clear text value has changed, and is encrypted using the
original encryption mechanism (see plugable encryption later).

A decrypted file might look like this:

```yaml
---
plain-property: You can see me

cipher-property : >
    DEC(1)::PKCS7[You can't see me]!

environments:
    development:
        host: localhost
        password: password
    production:
        host: prod.org.com
        password: >
            DEC(2)::PKCS7[securepassword]!

things:
    - thing 1
    -   - nested thing 1.0
        - >
            DEC(3)::PKCS7[secure nested thing 1.1]!
    -   - nested thing 2.0
        - nested thing 2.1
```

Whilst editing you can delete existing values and add new one using the same format (as below). Note that it is important to
omit the number in brackets for new values. If any duplicate IDs are found then the re-encryption process will be abandoned
by the eyaml tool.

    some_new_key: DEC::PKCS7[a new value to encrypt]!

### Encrypting an entire file

While not as common, sometimes you need to encrypt an entire file.  Maybe this
file is binary data that isn't meant for loading into an editor.  One example
might be a Kerberos keytab file.  No problem!  Just encrypt the entire file:

    $ eyaml encrypt -f filename

As with encrypting short strings on the command-line, the encrypted equivalent
will be sent to stdout as an ASCII text string and thus now plays nice with
your editor.  Notice that the file itself, however, remains unchanged.  The
output is presented in two blocks: once as a single, long string and once in
a nice line-wrapped form.  Copy the one of your preference, starting with the
`ENC[` and ending at the matching `]`.  Paste this into your Puppet or Hiera
file just like any other eyaml string and your done.  If the file is rather
large, you may wish to use a helper like `xclip` to copy the stdout directly to
your clipboard.

### Encrypting multiline values

The following step-by-step example shows you how to encrypt multiline values.

- Copy the YAML text below to a file named `multiline_example.eyaml`
```
---
accounts::key_sets:
  dummy:
    private: |
      ---- BEGIN SSH2 ENCRYPTED PRIVATE KEY ----
      Comment: "dummy-key-hiera-eyaml-issue-rsa-key-20200911"
      P2/56wAAANwAAAA3aWYtbW9kbntzaWdue3JzYS1wa2NzMS1zaGExfSxlbmNyeXB0e3JzYS
      1wa2NzMXYyLW9hZXB9fQAAAARub25lAAAAjQAAAIkAAAAGJQAAAP93ZtrMIRZutZ/SZUyw
      JWwyI4YxNvr5tBt9UnSJ7K0+rQAAAQDohO1ykUahsogS+ymM6o9WEmdROJZpWShCqdv8Dj
      2roQAAAIDG1G8hY90Xlz/YiFhDZLLWAAAAgOzMWTfAlHbJ4AdEhG5uU/EAAACA+1/AlcSr
      QEPM5xLW0unCsQ==
      ---- END SSH2 ENCRYPTED PRIVATE KEY ----
```

- Use `edit` to ...
  - replace '|' with '>',
  - prepend `DEC::PKCS7[` before the first line,
  - remove all whitespaces used for indentation,
  - and append `]!` to the last line of the multiline value.

`eyaml edit multiline_example.eyaml`
```
---
accounts::key_sets:
  dummy:
    private: >
      DEC::PKCS7[---- BEGIN SSH2 ENCRYPTED PRIVATE KEY ----
Comment: "dummy-key-hiera-eyaml-issue-rsa-key-20170123"
P2/56wAAANwAAAA3aWYtbW9kbntzaWdue3JzYS1wa2NzMS1zaGExfSxlbmNyeXB0e3JzYS
1wa2NzMXYyLW9hZXB9fQAAAARub25lAAAAjQAAAIkAAAAGJQAAAP93ZtrMIRZutZ/SZUyw
JWwyI4YxNvr5tBt9UnSJ7K0+rQAAAQDohO1ykUahsogS+ymM6o9WEmdROJZpWShCqdv8Dj
2roQAAAIDG1G8hY90Xlz/YiFhDZLLWAAAAgOzMWTfAlHbJ4AdEhG5uU/EAAACA+1/AlcSr
QEPM5xLW0unCsQ==
---- END SSH2 ENCRYPTED PRIVATE KEY ----]!
```
```
# resulting encrypted file
---
accounts::key_sets:
  dummy:
    private: >
      ENC[PKCS7,MIIDTQYJKoZIhvcNAQcDoIIDPjCCAzoCAQAxggEhMIIBHQIBADAFMAACAQEw
      DQYJKoZIhvcNAQEBBQAEggEAXH7xB1xuzoMAqA/3jSXO0ZUR6+UCb3DsTTj3
      Lsrcx5oQBnJ/ml7GfBCPxBKfArZunLcnxmSk4hECKXdfgKsVjAa++JQWvtEm
      HUNTFqvwd76Ku+nMfI9c8g+X+l6obLjzWfJdg3t6Ja7CJKl8UNFtSmbfYKVi
      nZ0xBubgdY4plLAFcZyD5/A/lNFqwb051TRLbZOIRRfLUlRL7RNkKRC59Aog
      S5aJXjmqx6vRzFifNK0JFZvYHGD75TiHJ5LFjg4rjgFd43AnK8iNo773ZWP2
      48Gly5Zx7qVQDCDDi1YBgNFb0NIBQw+kWy7HcPH2REvPnXu/HV2FWvDP3Ond
      yr2EbTCCAg4GCSqGSIb3DQEHATAdBglghkgBZQMEASoEEH+CjZJ1gKfaQIrr
      N5zef7OAggHgBmRVsfaoiNEOzhmHZ5SxxZztmpBNtLv7mteaSqSL5o0TtKQh
      SDgxBhaQmlL51+JM1Jsnvqm57ikZhj7Vtek/vr5DhYhWs0AxttH5rNaw0zKU
      4bMppVu+SNKCtT+2Qw31x/S7gF7yVl+mwmXhq3qAj9ExWRX3d/8/zTuC61Io
      f+7O6YUOucZ/m/YPrQnC5v7bDSKlIf1aFaKqukjM3QO8FZlAOHGPvRuWV2Om
      QIgxQE6F8r+bTkW3KiVIx5FEIthRZ90VS3tz/2wjj77svddBhlid9ov/0ard
      GGVNGsl1BFpLqxC0mpZXz237cL/aM58naqmX52J6YmC0xQM3DNmahWlYx1HV
      J/Ogk12pOYPLJB/09OuoHPzKC4WfpB9B7wAC6pghRkO/84cOw6rgSdbzze5W
      WMPvo181Y74BSBKhJDdO3lWYmEcDyx4TEsMUlpxd9PBDcOHqf9qHviXrwGzO
      oSm2bUV0Fum5ueU+D2vu3mO0yIQ6fwyvDZLBRjfJV7K/PyDz81feWT6+g38t
      AC27c0h8wk9b7HYfqG28nZE7F13qrhwCKnOaYLglsmbszNpRrBhfo1IHF6oM
      YZRZrnrGQg5qQcxMsLq37RAfRgkY0rRLs78EEAhkf4NDxw0A/ovt]
```
- Output of `eyaml decrypt -f multiline_example.eyaml`:
```
---
accounts::key_sets:
  dummy:
    private: |
  ---- BEGIN SSH2 ENCRYPTED PRIVATE KEY ----
  Comment: "dummy-key-hiera-eyaml-issue-rsa-key-20200911"
  P2/56wAAANwAAAA3aWYtbW9kbntzaWdue3JzYS1wa2NzMS1zaGExfSxlbmNyeXB0e3JzYS
  1wa2NzMXYyLW9hZXB9fQAAAARub25lAAAAjQAAAIkAAAAGJQAAAP93ZtrMIRZutZ/SZUyw
  JWwyI4YxNvr5tBt9UnSJ7K0+rQAAAQDohO1ykUahsogS+ymM6o9WEmdROJZpWShCqdv8Dj
  2roQAAAIDG1G8hY90Xlz/YiFhDZLLWAAAAgOzMWTfAlHbJ4AdEhG5uU/EAAACA+1/AlcSr
  QEPM5xLW0unCsQ==
  ---- END SSH2 ENCRYPTED PRIVATE KEY ----
```
  - The output *does NOT* have to be valid YAML for usage with Puppet.

Hiera
-----

To use eyaml with hiera and puppet, first configure hiera.yaml to use the eyaml backend.

Eyaml works with [Hiera 3.x](https://docs.puppet.com/hiera/latest), as well as with [Hiera 5](https://docs.puppet.com/puppet/latest/hiera_intro.html) (Puppet 4.9.3 and later).

### With Hiera 5

In Hiera 5, each hierarchy level has one designated backend, as well as its own independent configuration for that backend.

Hierarchy levels that use eyaml must set the following keys:

* `name`.
* `lookup_key` (must be set to `eyaml_lookup_key`).
* `path`/`paths`/`glob`/`globs` (choose one).
* `datadir` (can be omitted if you've set a default).
* `options` — a hash of eyaml-specific settings; by default, this should include `pkcs7_private_key` and `pkcs7_public_key`, or `pkcs7_public_key_env_var` and `pkcs7_private_key_env_var`, but alternate encryption plugins use alternate options. Anything from the old `:eyaml` config section (except `datadir`) goes here.

    You do not need to specify key names as `:symbols`; normal strings are fine.

``` yaml
---
version: 5
defaults:
  datadir: data
hierarchy:
  - name: "Secret data: per-node, per-datacenter, common"
    lookup_key: eyaml_lookup_key # eyaml backend
    paths:
      - "secrets/nodes/%{trusted.certname}.eyaml"  # Include explicit file extension
      - "secrets/location/%{facts.whereami}.eyaml"
      - "common.eyaml"
    options:
      pkcs7_private_key: /etc/puppetlabs/puppet/eyaml/private_key.pkcs7.pem
      pkcs7_public_key:  /etc/puppetlabs/puppet/eyaml/public_key.pkcs7.pem
  - name: "Normal data"
    data_hash: yaml_data # Standard yaml backend
    paths:
      - "nodes/%{trusted.certname}.yaml"
      - "location/%{facts.whereami}/%{facts.group}.yaml"
      - "groups/%{facts.group}.yaml"
      - "os/%{facts.os.family}.yaml"
      - "common.yaml"
```

Unlike with Hiera 3, there's no default file extension for eyaml files, so you can specify your own file extension directly in the path name.

For more details, see the [hiera.yaml (version 5) reference page](https://docs.puppet.com/puppet/latest/hiera_config_yaml_5.html).

### With Hiera 3

In Hiera 3, hierarchy levels don't have a backend assigned to them, and Hiera loops through the entire hierarchy for each backend. Options for the backend are set globally, in an `:eyaml` config section.

```yaml
---
:backends:
    - eyaml
    - yaml

:hierarchy:
    - %{environment}
    - common

:yaml:
    :datadir: '/etc/puppet/hieradata'
:eyaml:
    :datadir: '/etc/puppet/hieradata'

    # If using the pkcs7 encryptor (default)
    :pkcs7_private_key: /path/to/private_key.pkcs7.pem
    :pkcs7_public_key:  /path/to/public_key.pkcs7.pem

    # Optionally cache decrypted data (default: false)
    :cache_decrypted: false
```

Then, edit your hiera yaml files, and insert your encrypted values. The default eyaml file extension is .eyaml, however this can be configured in the :eyaml block to set :extension,

```yaml
:eyaml:
    :extension: 'yaml'
```

### Data formatting note

*Important Note:*
The eyaml backend will not parse internally json formatted yaml files, whereas the regular yaml backend will.
You'll need to ensure any existing yaml files using json format are converted to syntactically correct yaml format.

```yaml
---
plain-property: You can see me

cipher-property : >
    ENC[PKCS7,Y22exl+OvjDe+drmik2XEeD3VQtl1uZJXFFF2NnrMXDWx0csyqLB/2NOWefv
    NBTZfOlPvMlAesyr4bUY4I5XeVbVk38XKxeriH69EFAD4CahIZlC8lkE/uDh
    jJGQfh052eonkungHIcuGKY/5sEbbZl/qufjAtp/ufor15VBJtsXt17tXP4y
    l5ZP119Fwq8xiREGOL0lVvFYJz2hZc1ppPCNG5lwuLnTekXN/OazNYpf4CMd
    /HjZFXwcXRtTlzewJLc+/gox2IfByQRhsI/AgogRfYQKocZgFb/DOZoXR7wm
    IZGeunzwhqfmEtGiqpvJJQ5wVRdzJVpTnANBA5qxeA==]

environments:
    development:
        host: localhost
        password: password
    production:
        host: prod.org.com
        password: >
            ENC[PKCS7,Y22exl+OvjDe+drmik2XEeD3VQtl1uZJXFFF2NnrMXDWx0csyqLB/2NOWefv
            NBTZfOlPvMlAesyr4bUY4I5XeVbVk38XKxeriH69EFAD4CahIZlC8lkE/uDh
            jJGQfh052eonkungHIcuGKY/5sEbbZl/qufjAtp/ufor15VBJtsXt17tXP4y
            l5ZP119Fwq8xiREGOL0lVvFYJz2hZc1ppPCNG5lwuLnTekXN/OazNYpf4CMd
            /HjZFXwcXRtTlzewJLc+/gox2IfByQRhsI/AgogRfYQKocZgFb/DOZoXR7wm
            IZGeunzwhqfmEtGiqpvJJQ5wVRdzJVpTnANBA5qxeA==]

things:
    - thing 1
    -   - nested thing 1.0
        - >
            ENC[PKCS7,Y22exl+OvjDe+drmik2XEeD3VQtl1uZJXFFF2NnrMXDWx0csyqLB/2NOWefv
            NBTZfOlPvMlAesyr4bUY4I5XeVbVk38XKxeriH69EFAD4CahIZlC8lkE/uDh
            jJGQfh052eonkungHIcuGKY/5sEbbZl/qufjAtp/ufor15VBJtsXt17tXP4y
            l5ZP119Fwq8xiREGOL0lVvFYJz2hZc1ppPCNG5lwuLnTekXN/OazNYpf4CMd
            /HjZFXwcXRtTlzewJLc+/gox2IfByQRhsI/AgogRfYQKocZgFb/DOZoXR7wm
            IZGeunzwhqfmEtGiqpvJJQ5wVRdzJVpTnANBA5qxeA==]
    -   - nested thing 2.0
        - nested thing 2.1
```

Configuration file for eyaml
----------------------------

Default parameters for the eyaml command line tool can be provided by creating a configuration YAML file.

Config files will be read in following order:
* first from system-wide `/etc/eyaml/config.yaml`
* then from user home directory `~/.eyaml/config.yaml`
* then from current working directory `.eyaml/config.yaml`
* finally by anything referenced in the `EYAML_CONFIG` environment variable

The file takes any long form argument that you can provide on the command line. For example, to override the pkcs7 keys:
```yaml
---
pkcs7_private_key: './keys/eyaml/private_key.pkcs7.pem'
pkcs7_public_key: './keys/eyaml/public_key.pkcs7.pem'
```

Or to override to use GPG by default:
```yaml
---
encrypt_method: 'gpg'
gpg_gnupghome: './alternative_gnupghome'
gpg_recipients: 'sihil@example.com,gtmtech@example.com,tpoulton@example.com'
```

Pluggable Encryption
--------------------

hiera-eyaml backend is pluggable, so that further encryption types can be added as separate gems to the general mechanism which hiera-eyaml uses. Hiera-eyaml ships with one default mechanism of 'pkcs7', the encryption type widely used to sign smime email messages.

Other encryption types (if the gems for them have been loaded) can be specified using the following formats:

    ENC[PKCS7,SOME_ENCRYPTED_VALUE]         # a PKCS7 encrypted value
    ENC[GPG,SOME_ENCRYPTED_VALUE]           # a GPG encrypted value (hiera-eyaml-gpg)
    ... etc ...

When editing eyaml files, you will see that the unencrypted plaintext is marked in such a way as to identify the encryption method. This is so that the eyaml tool knows to encrypt it back using the correct method afterwards:

    some_key: DEC(1)::PKCS7[very secret password]!

### Encryption plugins

This is a list of available plugins:

 - [hiera-eyaml-gpg](https://github.com/sihil/hiera-eyaml-gpg) - Provide GPG encryption
 - [hiera-eyaml-plaintext](https://github.com/gtmtechltd/hiera-eyaml-plaintext) - This is a no-op encryption plugin that
   simply base64 encodes the values. It exists as an example plugin to create your own and to do integration tests on
   hiera-eyaml. **THIS SHOULD NOT BE USED IN PRODUCTION**
 - [hiera-eyaml-twofac](https://github.com/gtmtechltd/hiera-eyaml-twofac) - PKCS7 keypair + AES256 symmetric password for two-factor encryption
   Note that this plugin mandates the user enter a password. It is useful for non-automated scenarios, and is not advised to be used
   in conjunction with puppet, as it requires entry of a password over a terminal.
 - [hiera-eyaml-kms](https://github.com/adenot/hiera-eyaml-kms) - Encryption using AWS Key Management Service (KMS)
 - [hiera-eyaml-gkms](https://github.com/craigwatson/hiera-eyaml-gkms) - Encryption using Google Cloud KMS
 - [hiera-eyaml-vault](https://github.com/crayfishx/hiera-eyaml-vault) - Use the transit secrets engine from Vault for providing encryption.


### How-To's:

 - [How to use different Hiera/Eyaml keys for different environments using the AWS Parameter Store to store the encryption keys for Hiera/Eyaml](https://gist.github.com/FransUrbo/88b26033cb513a8aa569bd5392a427b1).

Notes
-----

If you do not specify an encryption method within ENC[] tags, it will be assumed to be PKCS7

Also remember that after encrypting your sensitive properties, if anyone has access to your git source,
they will see what the property was in previous commits before you encrypted. It's recommended that you
roll any passwords when switching from unencrypted to encrypted properties. eg, Developers having write
access to a DEV branch will be able to read/view the contents of the PRD branch, as per the design of GIT.

Github has a great guide on removing sensitive data from repos here:
https://help.github.com/articles/remove-sensitive-data


Troubleshooting
---------------

### Installing from behind a corporate/application proxy

    $ export HTTP_PROXY=http://yourcorporateproxy:3128/
    $ export HTTPS_PROXY=http://yourcorporateproxy:3128/

then run your install

    $ gem install hiera-eyaml


Issues
------

If you have found a bug then please raise an issue here on github.

Some of us hang out on #voxpupuli on [Libera.Chat](https://libera.chat/), please drop by if you want to say hi or have a question.


Tests
-----

**NOTE** Some testing requirements are not supported on Windows

In order to run the tests, simply run `cucumber` in the top level directory of the project.

You'll need to have a few requirements installed:

  * `expect` (via yum/apt-get or system package)
  * `aruba` (gem)
  * `cucumber` (gem)
  * `puppet` (gem)
  * `hiera-eyaml-plaintext` (gem)


Authors
-------

- [Tom Poulton](http://github.com/TomPoulton) - Initial author. eyaml backend.
- [Geoff Meakin](http://github.com/gtmtech) - Major contributor. eyaml command, tests, CI
- [Simon Hildrew](http://github.com/sihil) - Contributor. eyaml edit sub command.
- [Robert Fielding](http://github.com/rooprob) - Contributor. eyaml recrypt sub command.
