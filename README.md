Hiera eYaml
===========

An alternative to [hiera-gpg](http://github.com/crayfishx/hiera-gpg) for encrypting sensitive
data within yaml type files to be used by Puppet.

The main reasons to create an alternative backend for hiera are summed up in
[this blog](http://slashdevslashrandom.wordpress.com/2013/06/03/my-griefs-with-hiera-gpg/)
which I stumbled on whilst looking for options, but the main one is the ability to
encrypt each value individually and not the whole file. This provides a bit more transparency
and allows those configuring Puppet to know where each value is defined.

I also ran into problems using hiera-gpg (actually not hiera-gpg's fault
but another project it uses internally [ruby-gpgme](http://github.com/ueno/ruby-gpgme))
and the whole thing seemed a bit brittle.

Usage
=====

The Hiera eYaml uses yaml formatted files with .eyaml extension. Simply wrap your
encrypted string with ENC[ ] and place it in an eyaml file. You can mix your plain values
in as well or separate them into different files.

<pre>
---
plain-property: You can see me

encrypted-property : >
    ENC[c0sjg2W8y0j3gNGSR2uqowrS6V33ueseZUTDTwodXnk0+TBNnsVrCdp2WXaE
    Jet0v9UOd6uOpZjW0bAyzWgs4ZGbeZbdxNmWeQ9grh8KxOCN/WgAcAVjytaj
    Estq5AkLDin4hBixGHgYd4C6//kemewUYwI0oQhISlLUghIH2Bh4zPO3wrvo
    7yeANR7qv5em11+r1gKnbE+BXviSONWr/MLe2ey6Rc2z+E4FWOtYQqLvF/87
    nrR8tlK+aQT0v8dEXTnpYYCHWv5nJouq+SmjdgZJcOhtZayokWGSPBQxLR4w
    ekkeDb0BHKk05CM8OqVe6KTst9WIXErxWqXwhKBV/g==]
</pre>

eYaml also supports encrypted values within arrays, hashes, nested arrays and nested hashes

N.B. when using the multi-line string syntax (i.e. >) **don't wrap encrypted strings with "" or ''**

Setup
=====

## Generate keys

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

## Install eYaml backend

I'm new to ruby and tight on deadlines so I will create a gem when I get a chance, but for now just
copy eyaml_backend.rb to the same directory as the existing backends e.g.
/usr/lib/ruby/site_ruby/1.8/hiera/backend

You can find the directory by running

    $ sudo find / -name yaml_backend.rb

## Configure Hiera

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
    :private_key: /etc/hiera/gpg
</pre>

## Encrypt value

Copy public_key.pem created earlier to any machine where values will be encrypted and
use openssl to encrypt sensitive strings.

There is a very basic helper file encrypt_value.rb which will do this for you. Just copy the
public key to the same directory as encrypt_value.rb (or vice versa), navigate to that
directory and run

    $ ruby encrypt_value.rb "my secret thing"

The encrypted value is printed to the command line

If you wish to rename your key or keep it in another directory run

    $ ruby encrypt_value.rb "my secret thing" /path/to/key/my_key.pem

## Insert encrypted value

As above, once the value is encrypted, wrap it in ENC[ ] and place it in the .eyaml file.

ToDo
====

