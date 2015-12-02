#!/bin/bash
# This is a script to run ansible-pull on an FGCI compute node
# It is first grabbed with curl during kickstart
# It's initially set to execute every 15 minutes
# Local.yml itself changes cron interval after execution.

# Setup the ansible-pull fgci work dir
mkdir -p $HOME/.ansible/pull/$HOSTNAME
cd $HOME/.ansible/pull/$HOSTNAME
if [ ! -d ".git" ]; then
/usr/bin/git clone https://github.com/CSC-IT-Center-for-Science/fgci-ansible.git .
else
# If the .git directory exists then only run git pull
/usr/bin/git pull
fi
# Install all the ansible role dependencies
/usr/bin/ansible-galaxy install -r requirements.yml -f -i

# Get the ansible hosts file 
/usr/bin/curl http://{{ kickstart_server_ip }}/hosts > /root/hosts

# customizable random delay in seconds, fgci-ansible/local.yml playbook, master branch and /root/hosts inventory file
/usr/bin/ansible-pull -s {{ ansible_pull_sleep }} -U https://github.com/CSC-IT-Center-for-Science/fgci-ansible.git -C master -i /root/hosts

# Grab the latest ansible-pull-script.sh
/usr/bin/ansible -i /root/hosts -m get_url -a "url=http://{{ kickstart_server_ip }}/ansible-pull-script.sh dest=/usr/local/bin/" localhost
