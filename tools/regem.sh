#!/bin/bash

gem uninstall hiera-eyaml --executables
rake build
gem install pkg/hiera-eyaml
eyaml -v

scp pkg/hiera-eyaml-1.2.0.gem vagrant@192.168.168.101:/tmp

