#!/bin/bash

DEBUG=0

bold=$(tput bold)
normal=$(tput sgr0)

# Loop over the directories in example/group_vars
# Loop over all the variables that are defined in examples/group_vars/$examplegroup
# Skip lines which begins with a space, comment or empty line (skips contents of dictionaries and lists)
# Only show unique entries and only store the variable name
# Grep for each variable in group_vars/$exampledir

exdir="examples/group_vars"

for exampledir in $(ls $exdir); do
	#echo $exampledir
	for examplevar in $(grep -hR \: $exdir/$exampledir | grep -ve "^[[:space:]]" -e ^# -e ^$|sort|uniq|cut -d ":" -f1); do 
		grep -R "$examplevar" "group_vars/$exampledir" 2>&1 >/dev/null
		if [ "$?" != 0 ]; then
			echo "variable ${bold}$examplevar${normal} is in examples/$exampledir but not in ${bold}group_vars/$exampledir${normal}"
		else
			if [ "$DEBUG" != 0 ]; then
				echo "$examplevar from examples/$exampledir is set in group_vars/$exampledir"
			fi
		fi
	done
done
