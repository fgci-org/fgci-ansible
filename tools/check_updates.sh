#!/bin/bash
# Check if there have been updates to the fgci-ansible git repo - it uses the same branch that is checked out locally

usage() {
echo "$0 [-q] [-r]"
echo " "
echo "Check if there have been updates to the fgci-ansible git repo or roles."
echo "for the -q or no argument arguments this script uses the same branch that is checked out locally"
echo " "
echo "Usage Example:"
echo "$ cd fgci-ansible"
echo "$ git checkout master"
echo "$ export GITHUB_TOKEN="my-token-here" # https://github.com/settings/tokens"
echo "$ bash tools/$0"
echo "https://github.com/fgci-org/fgci-ansible/compare/6171df84bbf4a513993309dc1a6350ea4a6751e6...c499024f2b44cd2207de9f74c8341b5c7c7f40f0"
echo " "
echo "Arguments:"
echo " -q # don't print anything, just return code 1 if they do not match"
echo " -r # check if the latest role version/commit on github is different than the one defined in requirements.yml . This requires bash environment variable GITHUB_TOKEN to be defined."
echo " no argument # print a URL to visually compare the commits. If they are even then just print OK"

exit 20

}

#BASEURL=https://github.com/fgci-org/fgci-ansible/compare/{{ LATEST_COMMIT_IN_LOCAL_CLONE }}...{{ LATEST_COMMIT_ON_GITHUB }}
BASEURL="https://github.com/fgci-org/fgci-ansible/compare"

DEBUG=0

 if [ "$1" == "-h" ]; then
   usage
 fi

## Checking if the GITHUB_TOKEN variable is defined
## If it is not defined we stop if it's a -r argument, but allow through -q without printing anything and if no arguments are used then we print some more.
if [ "x$GITHUB_TOKEN" == "x" ]; then
 curlcmd="curl"
 if [ "$1" != "-q" ]; then
   echo "Error: GITHUB_TOKEN variable is not defined"
   echo "  "
   echo "Create an oAUTH GITHUB_TOKEN on https://github.com/settings/tokens."
   echo "before running check_updates.sh set the GITHUB_TOKEN variable:"
   echo "export GITHUB_TOKEN=your-token-with-no-scope"
   echo "  "
   echo "no-scope is needed on the token"
   echo "Without this the github api allows only 60 queries in one hour."
   if [ "$1" == "" ]; then
     echo "But as we only check one repo (fgci-ansible) then we run this script anyway"
   else
     exit 17
   fi
 fi
else
 curlcmd="curl -H \"Authorization: token "$GITHUB_TOKEN"\""
fi
##
if [ "$DEBUG" != "0" ]; then echo "curlcmd: $curlcmd"; fi

check_roles() {
	bad_repo_counter=0
	# - src: https://github.com/CSCfi/ansible-role-fgci-repo
	# - src: https://github.com/CSCfi/ansible-role-fgci-bash
	if [ -f "requirements.yml" ]; then
		rpath="requirements.yml"
	else
		rpath="../requirements.yml"
	fi
  	roles_list=$(grep src: $rpath|cut -d " " -f3)
	
	for role in $roles_list; do
		#sleep 5
		# https://developer.github.com/v3/#rate-limiting
		# which says for unauthenticated it's 60 requests per hour
		role_version=""
		role_version="$(grep src: -A3 $rpath|grep -A3 $role\$|grep version|grep -v '#.*version'|cut -d ":" -f2|sed -e 's/\s//')"
		if [ "$DEBUG" != "0" ]; then echo "###$role##"; fi
		role_shorter_github_name="$(echo "$role"|cut -d "." -f2|sed -e 's/^com\///')"
		role_api_url_base="https://api.github.com/repos"
		role_api_url_suffix="git/refs/heads/master"
		role_api_url_tag_suffix="git/refs/tags"
		role_api_url=""$role_api_url_base"/"$role_shorter_github_name"/"$role_api_url_suffix""
		role_api_url_latest=""$role_api_url_base"/"$role_shorter_github_name"/releases/latest"
		role_api_url_ext_tags=""$role_api_url_base"/"$role_shorter_github_name"/"$role_api_url_tag_suffix""
		# We check if there is number.number.number anywhere in the version - then we assume it's a tag/release and not a commit
		# The tags can be gotten from at least two places:
		# https://api.github.com/repos/fgci-org/ansible-role-fgci-install/releases/latest
		# https://api.github.com/repos/fgci-org/ansible-role-fgci-install/git/refs/tags

		if [[ "$role_version" =~ [0-9]\.[0-9]\.[0-9] ]]; then
		  # $role_version is a versiony looking number - like 1.1.2
  	  	  if [ "$DEBUG" != "0" ]; then
    	            ### Here the curl command can be modified to also print verbosely and http headers if DEBUG=1 (add -iv to the -qsf)
		    if [[ "$role_api_url_latest" =~ CSC ]]; then
  		      thecurl="$(curl -H "Authorization: token $GITHUB_TOKEN" -qsf "$role_api_url_latest"|grep tag_name|cut -d ":" -f2|cut -d '"' -f2)"
		    else
		      # grab the last ref tag
  		      thecurl="$(curl -H "Authorization: token $GITHUB_TOKEN" -qsf "$role_api_url_ext_tags"|grep ref\":|grep tags|tail -1|cut -d "/" -f3|sed -e 's/\",$//')"
		    fi
		  else
		    if [[ "$role_api_url_latest" =~ CSC ]]; then
  		      thecurl="$(curl -H "Authorization: token $GITHUB_TOKEN" -qsf "$role_api_url_latest"|grep tag_name|cut -d ":" -f2|cut -d '"' -f2)"
		    else
		      # grab the last ref tag
  		      thecurl="$(curl -H "Authorization: token $GITHUB_TOKEN" -qsf "$role_api_url_ext_tags"|grep ref\":|grep tags|tail -1|cut -d "/" -f3|sed -e 's/\",$//')"
		    fi
		  fi
		  if [ "$DEBUG" != "0" ]; then echo $role_api_url_latest; fi
		  LATESTREMOTERELEASE="$thecurl"
		  if [ "$?" != 0 ]; then
		      echo "Halting, could not curl $role_api_url"
		      exit 13
		  fi
		  if [ "$LATESTREMOTERELEASE" == "" ]; then
		    if [[ "$role_api_url_latest" =~ CSC ]]; then
		    	echo "$role_api_url_latest Could not figure out the LATESTREMOTERELEASE - is github rate limiting you or does the URL for some other reason not work?"
		    	exit 15
		    else
		  	echo "$role Could not figure out last release but it's not a CSC repo so we don't stop the script. Check this repo manually."
		    fi
		  fi
	          if [ "$role_version" != "$LATESTREMOTERELEASE" ]; then
		    if [ "$LATESTREMOTERELEASE" != "" ]; then
		    	echo "$role tag can be updated - current: $role_version latest: $LATESTREMOTERELEASE"
			let "bad_repo_counter += 1"
		    fi
		  else
		    if [ "$DEBUG" != "0" ]; then echo "$role_version and $LATESTREMOTERELEASE"; fi
		  fi
		else
		  # $role_version is not a versiony looking number - perhaps a sha commit?
		  # https://api.github.com/repos/fgci-org/ansible-role-fgci-install/git/refs/heads/master
  		  thecurl="$(curl -H "Authorization: token $GITHUB_TOKEN" -qsf "$role_api_url"|grep sha|cut -d ":" -f2|cut -d '"' -f2)"
		  REMOTESHA="$thecurl"
		    if [ "$?" != 0 ]; then
		        echo "Halting, could not curl $role_api_url"
		        exit 13
		    fi
            	    if [ "$role_version" != "$REMOTESHA" ]; then
		    	echo "$role sha can be updated - current: $role_version latest: $REMOTESHA"
			let "bad_repo_counter += 1"
		    else
		      if [ "$DEBUG" != "0" ]; then echo "$role_version and $REMOTESHA"
		        echo "$role latest commit used"
	      	      fi
	    	    fi
		fi
        if [ "$DEBUG" != "0" ]; then echo "$bad_repo_counter"; fi
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
	REMOTESHA="$($curlcmd -qsf https://api.github.com/repos/fgci-org/fgci-ansible/git/refs/heads/$LOCALBRANCH|grep sha|cut -d ":" -f2|cut -d '"' -f2)"
	if [ "$?" != 0 ]; then
	    echo "Halting, could not curl https://api.github.com/repos/fgci-org/fgci-ansible/git/refs/heads/$LOCALBRANCH"
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
            if [ "$bad_repo_counter" != "0" ]; then
              exit 1
            else
              exit 0
            fi
	  ;;
  	  -h)
	    usage
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

