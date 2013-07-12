Hiera eYaml
===========

A backend for Hiera that provides per-value asymmetric encryption of sensitive data
within yaml type files to be used by Puppet
(similar to [hiera-gpg](http://github.com/crayfishx/hiera-gpg))

The main reasons to create an alternative backend for hiera are summed up in
[this post](http://slashdevslashrandom.wordpress.com/2013/06/03/my-griefs-with-hiera-gpg/)
which I stumbled on whilst looking for options, but the main one is the ability to
encrypt each value individually and not the whole file. This provides a bit more transparency
and allows those configuring Puppet to know where each value is defined.

I also ran into problems using hiera-gpg (actually not hiera-gpg's fault
but another project it uses internally [ruby-gpgme](http://github.com/ueno/ruby-gpgme) 
which didn't seem to recognise my keychain)

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

    $ sudo mkdir -p /etc/hiera/keys
    $ sudo openssl genrsa -out /etc/hiera/keys/private_key.pem 2048
    $ sudo openssl rsa -in /etc/hiera/keys/private_key.pem -pubout -out /etc/hiera/keys/public_key.pem

This creates a public and private key with default names in the default location.

eYaml doesn't support keys with a passphrase yet, but as Craig Dunn explains in his
[post about hiera-gpg](http://www.craigdunn.org/2011/10/secret-variables-in-puppet-with-hiera-and-gpg)
"it would mean having the password stored in /etc/puppet/hiera.yaml as plaintext anyway,
so I don’t see that as adding much in the way of security."

Change the permissions so that the private key is only readable by the user that hiera (puppet) is
running as.

### Configure Hiera

Next configure hiera.yaml to use the eyaml backend

<pre>
---
:backends:
    - yaml
    - eyaml

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

Copy the public_key.pem created earlier to the keys subdirectory of this git repository.

There is a very basic helper file bin/encrypt_value.rb which will encrypt values for you 
based on the public_key.pem. Run:

    $ bin/encrypt_value.rb "my secret thing"

The encrypted value is printed to STDOUT

If you wish to rename your key or keep it in another directory run

    $ encrypt_value.rb "my secret thing" /path/to/key/my_key.pem

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

ToDo
====

It's not exactly the most compact syntax ever so I'll try and find a way of
slimming it down a bit. I did try using [Zlib](http://ruby-doc.org/stdlib-2.0/libdoc/zlib/rdoc/Zlib.html)
but that didn't really help much.

GPG seems to have this secure "feel to it" so there might be a better encryption method to use than
a pair of pem keys.

Thanks
======

Thank you to Craig Dunn for his work on hiera-gpg and corresponding blog post mentioned above,
it definitely made it easier to write this having his code as a reference.
