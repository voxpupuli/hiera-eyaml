Change log for hiera-eyaml
==========================

2.0.6
-----

 - #131 - Fix another EDITOR bug (#130) that could erase command line flags to the specified editor (@elyscape)

2.0.5
-----

 - #128 - Fix a bug (#127) that caused `eyaml edit` to break when `$EDITOR` was a command on PATH rather than a path to a command (@elyscape)

2.0.4
-----

 - Add change log
 - #118 - Some initial support for spaces in filenames (primarily targeted at windows platforms) (@elyscape)
 - #114 - Add new config file resolution so that a system wide /etc/eyaml/config.yaml is processed first (@gtmtech)
 - #112 - Improve debugging options and colorise output (@gtmtech)
 - #102 - Extension of temp files should be yaml to help editors provide syntax highlighting (@ColinHebert)
 - #90, #121, #122 - Add preamble in edit mode to make it easier to remember how to edit (@sihil)
 - #96, #111, #116 - Various updates to docs

2.0.3
-----
