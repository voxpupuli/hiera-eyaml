Hiera eyaml
===========

[![Build Status](https://travis-ci.org/TomPoulton/hiera-eyaml.png)](https://travis-ci.org/TomPoulton/hiera-eyaml)

hiera-eyaml is a backend for Hiera that provides per-value encryption of sensitive data within yaml files 
to be used by Puppet.

What's wrong with hiera-gpg?
============================

A few people found that [hiera-gpg](https://github.com/crayfishx/hiera-gpg) just wasn't cutting it for all use cases, 
one of the best expressed frustrations was 
[written back in June 2013](http://slashdevslashrandom.wordpress.com/2013/06/03/my-griefs-with-hiera-gpg/). So
[Tom created an initial version](http://themettlemonkey.wordpress.com/2013/07/15/hiera-eyaml-per-value-encrypted-backend-for-hiera-and-puppet/)
and this has since been refined into an elegant solution over the following months.

Unlike `hiera-gpg`, `hiera-eyaml`:

 - only encrypts the values (which allows files to be swiftly reviewed without decryption)
 - encrypts the value of each key individually (this means that `git diff` is meaningful)
 - includes a command line tool for encrypting, decrypting, editing and rotating keys (makes it almost as easy as using clear text files)
 - uses basic asymmetric encryption (PKCS#7) by default (doesn't require any native libraries that need to be compiled but allows only the
   pupper master to decrypt hiera values)
 - has a pluggable encryption framework so that GPG encryption can be used if you have the need for multiple keys and easier key rotation

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

To edit this you can use the command `eyaml -i important.eyaml` which will decrypt the file, fire up an editor with
the decrypted values and re-encrypt any edited values when you exit the editor. This tool makes editing your encrypted
files as simple as clear text files.

Setup
=====

### Installing hiera-eyaml

    $ gem install hiera-eyaml

#### Installing from behind a corporate/application proxy
    $ export HTTP_PROXY=http://yourcorporateproxy:3128/
    $ export HTTPS_PROXY=http://yourcorporateproxy:3128/

then run your install

    $ gem install hiera-eyaml

### Generate keys

The first step is to create a pair of keys:

    $ eyaml -c

This creates a public and private key with default names in the default location. (./keys)

#### Storing the keys securely when using Puppet

Since the point of using this module is to securely store sensitive information, it's important to store these keys securely.
If using Hiera with Puppet, Your puppetmaster will need to access these keys to perform decryption when the puppet agent runs on a remote node.
So for this reason, a suggested location might be to store them in:

    /etc/puppet/secure/keys

(Using a secure/keys/ subfolder is so that you can still store other secure puppet files in the secure/ folder that might not be related to this module.)

The permissions for this folder should allow the puppet user (normally 'puppet') execute access to the keys directory, read only access to the keys themselves and restrict everyone else:

    $ chown -R puppet:puppet /etc/puppet/secure/keys
    $ chmod -R 0500 /etc/puppet/secure/keys
    $ chmod 0400 /etc/puppet/secure/keys/*.pem
    $ ls -lha /etc/puppet/secure/keys
    -r-------- 1 puppet puppet 1.7K Sep 24 16:24 private_key.pkcs7.pem
    -r-------- 1 puppet puppet 1.1K Sep 24 16:24 public_key.pkcs7.pem


### Encryption

To encrypt something, you only need the public_key, so distribute that to people creating hiera properties

    $ eyaml -e -f filename            # Encrypt a file
    $ eyaml -e -s 'hello there'       # Encrypt a string
    $ eyaml -e -p                     # Encrypt a password (prompt for it)

Use the -l parameter to pass in a label for the encrypted value,

    $ eyaml -e -l 'some_easy_to_use_label' -s 'yourSecretString' --pkcs7-private-key /etc/puppet/secure/keys/private_key.pkcs7.pem --pkcs7-public-key /etc/puppet/secure/keys/public_key.pkcs7.pem


### Decryption

To decrypt something, you need the public_key and the private_key.

To test decryption you can also use the eyaml tool if you have both keys

    $ eyaml -d -f filename               # Decrypt a file
    $ eyaml -d -s 'ENC[PKCS7,.....]'     # Decrypt a string

### eYaml files

Once you have created a few eyaml files, with a mixture of encrypted and non-encrypted properties, you can edit the encrypted values in place, using the special edit mode of the eyaml utility

    $ eyaml -i filename.eyaml         # Edit an eyaml file in place

Multiple Encryption Types
=========================

hiera-eyaml backend is pluggable, so that further encryption types can be added as separate gems to the general mechanism which hiera-eyaml uses. Hiera-eyaml ships with one default mechanism of 'pkcs7', the encryption type widely used to sign smime email messages.

Other encryption types (if the gems for them have been loaded) can be specified using the following formats:

<pre>
    ENC[PKCS7,SOME_ENCRYPTED_VALUE]         # a PKCS7 encrypted value
    ENC[GPG,SOME_ENCRYPTED_VALUE]           # a GPG encrypted value (hiera-eyaml-gpg)
    ... etc ...
</pre>

When editing eyaml files, you will see that the unencrypted plaintext is marked in such a way as to identify the encryption method. This is so that the eyaml tool knows to encrypt it back using the correct method afterwards:

<pre>
some_key: DEC::PKCS7[very secret password]!
</pre>

Hiera
=====

To use eyaml with hiera and puppet, first configure hiera.yaml to use the eyaml backend

<pre>
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

</pre>

Then, edit your hiera yaml files, and insert your encrypted values. The default eyaml file extension is .eyaml, however this can be configured in the :eyaml block to set :extension,

<pre>
:eyaml:
    :extension: 'yaml'
</pre>

*Important Note:*
The eYaml backend will not parse internally json formatted yaml files, whereas the regular yaml backend will.
You'll need to ensure any existing yaml files using json format are converted to syntactically correct yaml format.

<pre>
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
</pre>

Tests
=====

In order to run the tests, simply run `cucumber` in the top level directory of the project.

You'll need to have a few requirements installed:

  * `expect` (via yum/apt-get or system package)
  * `aruba` (gem)
  * `cucumber` (gem)
  * `puppet` (gem)

Notes
=====

If you do not specify an encryption method within ENC[] tags, it will be assumed to be PKCS7

Also remember that after encrypting your sensitive properties, if anyone has access to your git source,
they will see what the property was in previous commits before you encrypted. It's recommended that you
roll any passwords when switching from unencrypted to encrypted properties. eg, Developers having write
access to a DEV branch will be able to read/view the contents of the PRD branch, as per the design of GIT.

Github has a great guide on removing sensitive data from repos here:
https://help.github.com/articles/remove-sensitive-data

Authors
=======

- [Tom Poulton](http://github.com/TomPoulton) - Initial author. eyaml backend.
- [Geoff Meakin](http://github.com/gtmtech) - Major contributor. eyaml command, tests, CI
- [Simon Hildrew](http://github.com/sihil) - Contributor. eyaml edit sub command.
- [Robert Fielding](http://github.com/rooprob) - Contributor. eyaml recrypt sub command.