#!/bin/sh
#

/usr/bin/diff -rq examples/group_vars/ group_vars/ | grep -v "^Only in "
