#!/bin/bash

gem uninstall hiera-eyaml --executables
rake build
gem install pkg/hiera-eyaml
eyaml -v