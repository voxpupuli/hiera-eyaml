Hiera eyaml
===========

[![Build Status](https://travis-ci.org/TomPoulton/hiera-eyaml.png?branch=master)](https://travis-ci.org/TomPoulton/hiera-eyaml)

hiera-eyaml is a backend for Hiera that provides per-value encryption of sensitive data within yaml files 
to be used by Puppet.

:new: *v2.0 - commandline tool syntax has changed, see below for details*

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
 - has a pluggable encryption framework (e.g. GPG encryption ([hiera-eyaml-gpg](https://github.com/sihil/hiera-eyaml-gpg)) can be used 
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

    $ gem install hiera-eyaml

### Installing hiera-eyaml for the new [puppet-server](https://github.com/puppetlabs/puppet-server)

    $ puppetserver gem install hiera-eyaml

### Generate keys

The first step is to create a pair of keys:

    $ eyaml createkeys

This creates a public and private key with default names in the default location. (./keys)

#### Storing the keys securely when using Puppet

Since the point of using this module is to securely store sensitive information, it's important to store these keys securely.
If using Hiera with Puppet, Your puppetmaster will need to access these keys to perform decryption when the puppet agent runs on a remote node.
So for this reason, a suggested location might be to store them in `/etc/puppet/secure/keys` or `/var/lib/puppet/keys` depending on your setup.

The permissions for this folder should allow the puppet user (normally 'puppet') execute access to the keys directory, read only access to the keys themselves and restrict everyone else:

    $ chown -R puppet:puppet /etc/puppet/secure/keys
    $ chmod -R 0500 /etc/puppet/secure/keys
    $ chmod 0400 /etc/puppet/secure/keys/*.pem
    $ ls -lha /etc/puppet/secure/keys
    -r-------- 1 puppet puppet 1.7K Sep 24 16:24 private_key.pkcs7.pem
    -r-------- 1 puppet puppet 1.1K Sep 24 16:24 public_key.pkcs7.pem


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

### Editing eyaml files

Once you have created a few eyaml files, with a mixture of encrypted and non-encrypted properties, 
you can edit the encrypted values in place, using the special edit mode of the eyaml utility. Edit
mode opens a decrypted copy of the eyaml file in your `$EDITOR` and will encrypt and modified values
when you exit the editor.

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


Hiera
-----

To use eyaml with hiera and puppet, first configure hiera.yaml to use the eyaml backend

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
```

Then, edit your hiera yaml files, and insert your encrypted values. The default eyaml file extension is .eyaml, however this can be configured in the :eyaml block to set :extension,

```yaml
:eyaml:
    :extension: 'yaml'
```

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

Config files will be read first from `/etc/eyaml/config.yaml`, then from `~/.eyaml/config.yaml` and finally by anything referenced in the `EYAML_CONFIG` environment variable

The file takes any long form argument that you can provide on the command line. For example, to override the pkcs7 keys:
```yaml
---
pkcs7_private_key: '~/keys/eyaml/private_key.pkcs7.pem'
pkcs7_public_key: '~/keys/eyaml/public_key.pkcs7.pem'
```

Or to override to use GPG by default:
```yaml
---
encrypt_method: 'gpg'
gpg_gnupghome: '~/alternative_gnupghome'
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

Some of us hang out on #hiera-eyaml on freenode, please drop by if you want to say hi or have a question.


Tests
-----

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
