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

### Generate keys

The first step is to create a pair of keys on the Puppet master

    $ sudo mkdir -p /etc/hiera/keys
    $ sudo openssl genrsa -out /etc/hiera/keys/private_key.pem 2048
    $ sudo openssl rsa -in /etc/hiera/keys/private_key.pem -pubout -out /etc/hiera/keys/public_key.pem

This creates a public and private key with default names in the default location.

Change the permissions so that the private key is only readable by the user that hiera (puppet) is
running as.

### Install eYaml backend

Gem coming soon, for now just copy eyaml_backend.rb to the same directory as the existing backends e.g.
/usr/lib/ruby/site_ruby/1.8/hiera/backend

You can find the directory with:

    $ sudo find / -name yaml_backend.rb

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
    :private_key: /new/path/to/key/my_key.pem
</pre>

### Encrypt value

Copy public_key.pem created earlier to any machine where values will be encrypted and
use openssl to encrypt sensitive data.

There is a very basic helper file encrypt_value.rb which will do this for you. Just copy the
public key to the same directory as encrypt_value.rb (or vice versa), navigate to that
directory and run

    $ ruby encrypt_value.rb "my secret thing"

The encrypted value is printed to the command line

If you wish to rename your key or keep it in another directory run

    $ ruby encrypt_value.rb "my secret thing" /path/to/key/my_key.pem

### Insert encrypted value

As above, once the value is encrypted, wrap it with ENC[] and place it in the .eyaml file.

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
