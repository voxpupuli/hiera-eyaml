#!/bin/sh
TMPFILE=`mktemp`
cat $2 $1 > $TMPFILE
cp $TMPFILE $2
rm $TMPFILE
