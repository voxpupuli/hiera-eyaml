**Hiera-eyaml-web**
===================

Why?
===
I don't want my puppet developers to have to install hiera-eyaml on their workstations, or login to a server.  As a side benefit, it also means that you don't have to circulate the eyaml public key around.  Primary goal was to make things easy to encrypt secrets for hiera.

Installation
===
Ruby+eyaml
---
I went with simple, so there are 3 ruby scripts you'll need to put in an apache webroot as CGI scripts.  You may need to tweak compare.rb & encrypt.rb to match your environment.  Of course, you'll already need hiera-eyaml installed and keys generated as well.  

Apache
---
As previously stated you need a webroot to serve these CGI scripts, you can do that with an apache VirtualHost, Directory, or Location directive; your choice.  Additionally, you need to consider how authentication and authorization work.  Use available apache tools for this.  I chose to use mod_auth_cas since we already had a CAS server available.  Also, I ***strongly*** recommend forcing all traffic to this webroot over SSL for this webroot since you are transmitting secrets.  Be aware that whatever user owns the process of these CGI scripts is going to need access to your private & public eyaml keys.  You could grant specific access using setfacl, or use the apache SuExec module to change the owning user.  I've included my apache hiera_eyaml_web.conf as an example, but you should tailor your configuration to your environment and goals.

Functionality
===
This tool provide two functions.

First, if can take an arbitrary input and return back to you the eyaml encrypted string to put in your hiera data.  I did include a verification mode you can use if you suspect the tool is mangling your input badly.  Use it with care because it does return your secret back to you in plaintext on your screen.  I've also added the ability to upload a file in order to preserve line endings, non-printed characters, and formatting (i.e. SSL Certificates).

Second, you can provide two eyaml encrypted strings from your hiera data to see if they are the same in their decrypted forms.

I specifically didn't create a decrypt function in this tool because I viewed it as a security hole.  If you need a secret, go look at the puppet deployed version (assuming you have access) or login to the server and run the command manually (assuming you have access).  Generally, being able to compare a known secret to an unknown secret should be good enough.

You can view screenshots of the simple interface [here](http://imgur.com/a/GEgH1).