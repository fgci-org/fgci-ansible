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

check_roles() {
	# - src: https://github.com/CSC-IT-Center-for-Science/ansible-role-fgci-repo
	# - src: https://github.com/CSC-IT-Center-for-Science/ansible-role-fgci-bash
	if [ -f "requirements.yml" ]; then
		rpath="requirements.yml"
	else
		rpath="../requirements.yml"
	fi
  	roles_list=$(grep src: $rpath|cut -d " " -f3)
	for role in $roles_list; do
		sleep 5
		# https://developer.github.com/v3/#rate-limiting
		# which says for unauthenticated it's 60 requests per hour
		role_version=""
		role_version="$(grep src: -A3 $rpath|grep -A3 $role\$|grep version|cut -d ":" -f2|sed -e 's/\s//')"
		echo "###$role##"
		role_shorter_github_name="$(echo $role|cut -d "." -f2|sed -e 's/^com\///')"
		role_api_url_base="https://api.github.com/repos"
		role_api_url_suffix="git/refs/heads/master"
		role_api_url="$role_api_url_base/$role_shorter_github_name/$role_api_url_suffix"
		role_api_url_latest="$role_api_url_base/$role_shorter_github_name/releases/latest"
		# We check if there is number.number.number anywhere in the version - then we assume it's a tag/release and not a commit
		if [[ "$role_version" =~ [0-9]\.[0-9]\.[0-9] ]]; then
		  echo $role_api_url_latest
		  LATESTREMOTERELEASE="$(curl -qsf $role_api_url_latest|grep tag_name|cut -d ":" -f2|cut -d '"' -f2)"
		    if [ "$?" != 0 ]; then
		        echo "Halting, could not curl $role_api_url"
		        exit 13
		    fi
		    if [ "$LATESTREMOTERELEASE" == "" ]; then
		      echo "Could not figure out the LATESTREMOTERELEASE - is github rate limiting you?"
		      exit 15
		    fi
            	    if [ "$role_version" != "$LATESTREMOTERELEASE" ]; then
		      echo "$role_version and $LATESTREMOTERELEASE"
		      #echo "There is a newer version of $role out!"
		    else
		      echo "$role_version and $LATESTREMOTERELEASE"
	    	    fi
		else
		  REMOTESHA="$(curl -qsf $role_api_url|grep sha|cut -d ":" -f2|cut -d '"' -f2)"
		    if [ "$?" != 0 ]; then
		        echo "Halting, could not curl $role_api_url"
		        exit 13
		    fi
            	    if [ "$role_version" != "$REMOTESHA" ]; then
		      echo "There is a newer commit of $role out!"
		    else
		      echo "$role_version and $REMOTESHA"
	    	    fi
		fi
	done

}


check_fgci_ansible() {


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
	if [ "$REMOTESHA" == "" ]; then
	  echo "Could not figure out the REMOTESHA - is github rate limiting you?"
	  exit 14
	fi

}

case "$1" in
          -q)
	    check_fgci_ansible
            if [ "$LOCALSHA" != "$REMOTESHA" ]; then
              exit 1
            else
              exit 0
            fi
          ;;
          -r)
            check_roles
	  ;;
          *)
	    check_fgci_ansible
            if [ "$LOCALSHA" != "$REMOTESHA" ]; then
              echo $BASEURL/$LOCALSHA\...$REMOTESHA
              exit 1
            else
              echo "OK"
              exit 0
            fi
esac

