#!/bin/bash
perl -pi -e 's/(DEC::PKCS7\[.*?\]\!)/uc($1)/ge' $1

# echo $1

# echo -e "\n\n\n"

# cat $1
# echo -e "\n\n\n"