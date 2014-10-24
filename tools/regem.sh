#!/bin/bash

gem uninstall hiera-eyaml --executables
RAKE_OUT=`rake build`
echo ${RAKE_OUT}
VERSION=`echo ${RAKE_OUT} | awk '{print $2}'`
echo Installing version: ${VERSION} ...
gem install pkg/hiera-eyaml-${VERSION}.gem
eyaml version
