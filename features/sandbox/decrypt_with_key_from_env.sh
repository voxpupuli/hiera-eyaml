#!/bin/bash

export EYAML_PRIVATE_KEY=$(cat ./keys/private_key.pkcs7.pem)
eyaml decrypt --pkcs7-private-key=<(printenv EYAML_PRIVATE_KEY) -e $1
