Hiera eYaml
===========

A backend for Hiera that provides per-value asymmetric encryption of sensitive data
within yaml type files to be used by Puppet.

More info can be found [in this corresponding post](http://themettlemonkey.wordpress.com/2013/07/15/hiera-eyaml-per-value-encrypted-backend-for-hiera-and-puppet/).

The Hiera eYaml backend uses yaml formatted files with the .eyaml extension. Simply wrap your
encrypted string with ENC[] and place it in an eyaml file. You can mix your plain values
in as well or separate them into different files.

<pre>
---
plain-property: You can see me

encrypted-property: >
    ENC[Y22exl+OvjDe+drmik2XEeD3VQtl1uZJXFFF2NnrMXDWx0csyqLB/2NOWefv
    NBTZfOlPvMlAesyr4bUY4I5XeVbVk38XKxeriH69EFAD4CahIZlC8lkE/uDh
    jJGQfh052eonkungHIcuGKY/5sEbbZl/qufjAtp/ufor15VBJtsXt17tXP4y
    l5ZP119Fwq8xiREGOL0lVvFYJz2hZc1ppPCNG5lwuLnTekXN/OazNYpf4CMd
    /HjZFXwcXRtTlzewJLc+/gox2IfByQRhsI/AgogRfYQKocZgFb/DOZoXR7wm
    IZGeunzwhqfmEtGiqpvJJQ5wVRdzJVpTnANBA5qxeA==]
</pre>

eYaml also supports encrypted values within arrays, hashes, nested arrays and nested hashes 
(see below for examples)

N.B. when using the multi-line string syntax (i.e. >) **don't wrap encrypted strings with "" or ''**

Setup
=====

### Installing hiera-eyaml

    $ gem install hiera-eyaml

### Generate keys

The first step is to create a pair of keys on the Puppet master

    $ eyaml -c

This creates a public and private key with default names in the default location. (/etc/hiera/keys directory)

### Encryption

    To encrypt something, you only need the public_key, so distribute that to people creating hiera properties

    $ eyaml -e filename               # Encrypt a file
    $ eyaml -e -s text                # Encrypt some text
    $ eyaml -e -p                     # Encrypt a password (prompt for it)

### Decryption

    To decrypt something, you need the public_key and the private_key on the puppet master.

    To test decryption you can also use the eyaml tool if you have both keys

    $ eyaml -d filename                  # Decrypt a file (PEM format)
    $ eyaml -d -s SOME-ENCRYPTED-TEXT    # Decrypt some text

Change the permissions so that the private key is only readable by the user that hiera (puppet) is
running as.

### Configure Hiera

Next configure hiera.yaml to use the eyaml backend

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

    # Optional. Default is /etc/hiera/keys/private_key.pem
    :private_key: /new/path/to/key/private_key.pem

    # Optional. Default is /etc/hiera/keys/public_key.pem
    :public_key:  /new/path/to/key/public_key.pem
</pre>

### YAML files

  Once the value is encrypted, wrap it with ENC[] and place it in the .eyaml file.

Usages:
<pre>
---
plain-property: You can see me

cipher-property : >
    ENC[Y22exl+OvjDe+drmik2XEeD3VQtl1uZJXFFF2NnrMXDWx0csyqLB/2NOWefv
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
            ENC[Y22exl+OvjDe+drmik2XEeD3VQtl1uZJXFFF2NnrMXDWx0csyqLB/2NOWefv
            NBTZfOlPvMlAesyr4bUY4I5XeVbVk38XKxeriH69EFAD4CahIZlC8lkE/uDh
            jJGQfh052eonkungHIcuGKY/5sEbbZl/qufjAtp/ufor15VBJtsXt17tXP4y
            l5ZP119Fwq8xiREGOL0lVvFYJz2hZc1ppPCNG5lwuLnTekXN/OazNYpf4CMd
            /HjZFXwcXRtTlzewJLc+/gox2IfByQRhsI/AgogRfYQKocZgFb/DOZoXR7wm
            IZGeunzwhqfmEtGiqpvJJQ5wVRdzJVpTnANBA5qxeA==]

things:
    - thing 1
    -   - nested thing 1.0
        - >
            ENC[Y22exl+OvjDe+drmik2XEeD3VQtl1uZJXFFF2NnrMXDWx0csyqLB/2NOWefv
            NBTZfOlPvMlAesyr4bUY4I5XeVbVk38XKxeriH69EFAD4CahIZlC8lkE/uDh
            jJGQfh052eonkungHIcuGKY/5sEbbZl/qufjAtp/ufor15VBJtsXt17tXP4y
            l5ZP119Fwq8xiREGOL0lVvFYJz2hZc1ppPCNG5lwuLnTekXN/OazNYpf4CMd
            /HjZFXwcXRtTlzewJLc+/gox2IfByQRhsI/AgogRfYQKocZgFb/DOZoXR7wm
            IZGeunzwhqfmEtGiqpvJJQ5wVRdzJVpTnANBA5qxeA==]
    -   - nested thing 2.0
        - nested thing 2.1
</pre>

Authors
=======

- [Tom Poulton](http://github.com/TomPoulton) - Initial author. eyaml backend.
- [Geoff Meakin](http://github.com/gtmtech) - Major contributor. eyaml command.