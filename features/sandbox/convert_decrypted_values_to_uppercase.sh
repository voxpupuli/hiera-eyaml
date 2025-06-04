#!/bin/sh
perl -pi -e 's/(DEC\(\d+\)::[A-Z0-9]+\[.*?\]\!)/uc($1)/ge' $1
