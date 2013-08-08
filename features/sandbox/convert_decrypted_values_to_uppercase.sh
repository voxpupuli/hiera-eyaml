#!/bin/bash
perl -pi -e 's/(DEC::[A-Z0-9]+\[.*?\]\!)/uc($1)/ge' $1
