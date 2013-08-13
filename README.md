Hiera eYaml
===========

A backend for Hiera that provides per-value asymmetric encryption of sensitive data
within yaml type files to be used by Puppet.

More info can be found [in this corresponding post](http://themettlemonkey.wordpress.com/2013/07/15/hiera-eyaml-per-value-encrypted-backend-for-hiera-and-puppet/).

The Hiera eYaml backend uses yaml formatted files with the .eyaml extension. Simply prefix your
encrypted string with the encryption method (PKCS7,) wrap it with ENC[] and place it in an eyaml file. You can mix your plain values in as well or separate them into different files.

Example:

<pre>
---
plain-property: You can see me

encrypted-property: >
    ENC[PKCS7,Y22exl+OvjDe+drmik2XEeD3VQtl1uZJXFFF2NnrMXDWx0csyqLB/2NOWefv
    NBTZfOlPvMlAesyr4bUY4I5XeVbVk38XKxeriH69EFAD4CahIZlC8lkE/uDh
    jJGQfh052eonkungHIcuGKY/5sEbbZl/qufjAtp/ufor15VBJtsXt17tXP4y
    l5ZP119Fwq8xiREGOL0lVvFYJz2hZc1ppPCNG5lwuLnTekXN/OazNYpf4CMd
    /HjZFXwcXRtTlzewJLc+/gox2IfByQRhsI/AgogRfYQKocZgFb/DOZoXR7wm
    IZGeunzwhqfmEtGiqpvJJQ5wVRdzJVpTnANBA5qxeA==]
</pre>

eYaml supports multiple encryption types, and encrypted values can occur within arrays, hashes, nested arrays and nested hashes 

Setup
=====

### Installing hiera-eyaml

    $ gem install hiera-eyaml

### Generate keys

The first step is to create a pair of keys:

    $ eyaml -c

This creates a public and private key with default names in the default location. (./keys)

### Encryption

    To encrypt something, you only need the public_key, so distribute that to people creating hiera properties

    $ eyaml -e -f filename            # Encrypt a file
    $ eyaml -e -s 'hello there'       # Encrypt a string
    $ eyaml -e -p                     # Encrypt a password (prompt for it)

### Decryption

    To decrypt something, you need the public_key and the private_key.

    To test decryption you can also use the eyaml tool if you have both keys

    $ eyaml -d -f filename               # Decrypt a file
    $ eyaml -d -s 'ENC[PKCS7,.....]'     # Decrypt a string

### EYaml files

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
    :pkcs7_private_key: /path/to/private_key_file.pem
    :pkcs7_public_key:  /path/to/public_key_file.pem

</pre>

Then, edit your hiera yaml files (renaming them with the .eyaml extension), and insert your encrypted values:

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

Notes
=====

If you do not specify an encryption method within ENC[] tags, it will be assumed to be PKCS7

Authors
=======

- [Tom Poulton](http://github.com/TomPoulton) - Initial author. eyaml backend.
- [Geoff Meakin](http://github.com/gtmtech) - Major contributor. eyaml command.
