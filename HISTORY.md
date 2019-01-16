## v2.1.0 (2016-03-02)

 - (#187) - Change the way third party highline library is imported to avoid memory leak when running under puppet server (@petems)
 - (#181) - Improve test suite to run against a variety of puppet versions (@peculater)

## v2.0.8 (2015-04-15)

 - (#149) - Fix to tempfile permissions and invalid editor scenario (@elyscape)

## v2.0.7 (2015-03-04)

 - (#142) - Fixed highline dependency to exclude newer versions that are not compatible with ruby 1.8.7 (@elyscape)
 - (#136) - \t and \r characters are now supported in encrypted blocks (@elyscape)
 - (#138) - Added missing tags and new tagging tool (@elyscape)

## v2.0.6 (2014-12-13)

 - (#131) - Fix another EDITOR bug (#130) that could erase command line flags to the specified editor (@elyscape)

## v2.0.5 (2014-12-11)

 - (#128) - Fix a bug (#127) that caused `eyaml edit` to break when `$EDITOR` was a command on PATH rather than a path to a command (@elyscape)

## v2.0.4 (2014-11-24)

 - Add change log
 - (#118) - Some initial support for spaces in filenames (primarily targeted at windows platforms) (@elyscape)
 - (#114) - Add new config file resolution so that a system wide /etc/eyaml/config.yaml is processed first (@gtmtech)
 - (#112) - Improve debugging options and colorise output (@gtmtech)
 - (#102) - Extension of temp files should be yaml to help editors provide syntax highlighting (@ColinHebert)
 - (#90), #121, #122 - Add preamble in edit mode to make it easier to remember how to edit (@sihil)
 - (#96), #111, #116 - Various updates to docs
