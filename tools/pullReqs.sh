#!/bin/sh
#

# Install all the ansible roles that we depend on
/usr/bin/ansible-galaxy install -r requirements.yml --force

# Update requirements_mirror.yml for ansible-pull-script 
# sync group_ and host_vars to the install node
# update ansible-pull-script on the install node
# send a flowdock notification to fgci admins

ansible-playbook install.yml --tags=fgci-install,flowdock --diff -e flowdock_from_address=pullReqs@{{siteDomain}}
