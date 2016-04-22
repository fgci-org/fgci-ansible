#!/bin/bash
# Check if there have been updates to the fgci-ansible git repo - it uses the same branch that is checked out locally
# Usage Example:
# $ cd fgci-ansible
# $ git checkout master
# $ bash tools/check_updates.sh
# https://github.com/CSC-IT-Center-for-Science/fgci-ansible/compare/6171df84bbf4a513993309dc1a6350ea4a6751e6...c499024f2b44cd2207de9f74c8341b5c7c7f40f0
# Arguments:
# -q # don't print anything, just return code 1 if they do not match
# anything or nothing # print a URL to visually compare the commits
#

#BASEURL=https://github.com/CSC-IT-Center-for-Science/fgci-ansible/compare/{{ LATEST_COMMIT_IN_LOCAL_CLONE }}...{{ LATEST_COMMIT_ON_GITHUB }}
BASEURL=https://github.com/CSC-IT-Center-for-Science/fgci-ansible/compare

LOCALSHA="$(git rev-parse HEAD 2>/dev/null)"
if [ "$?" != 0 ]; then
    echo "Halting, could not get the last commit in the local git repository, is $PWD in a git repository?"
    exit 10
fi
LOCALBRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)"
if [ "$?" != 0 ]; then
    echo "Halting, could not get local branch, is $PWD in a git repository?"
    exit 11
fi
REMOTESHA="$(curl -qsf https://api.github.com/repos/CSC-IT-Center-for-Science/fgci-ansible/git/refs/heads/$LOCALBRANCH|grep sha|cut -d ":" -f2|cut -d '"' -f2)"
if [ "$?" != 0 ]; then
    echo "Halting, could not curl https://api.github.com/repos/CSC-IT-Center-for-Science/fgci-ansible/git/refs/heads/$LOCALBRANCH"
    exit 12
fi

case "$1" in
          -q)
            if [ "$LOCALSHA" != "$REMOTESHA" ]; then
              exit 1
            else
              exit 0
            fi
          ;;
          *)
            if [ "$LOCALSHA" != "$REMOTESHA" ]; then
              echo $BASEURL/$LOCALSHA\...$REMOTESHA
              exit 1
            else
              echo "OK"
              exit 0
            fi
esac

