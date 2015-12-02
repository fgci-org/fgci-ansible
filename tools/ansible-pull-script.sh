#!/bin/bash
# This is a script to run ansible-pull on an FGCI compute node
# It is grabbed with curl during kickstart

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

# Get the hosts file 
/usr/bin/ansible -m get_url -a "url=http://{{ kickstart_server_ip }}/hosts dest=/root/ mode=0644" localhost

# 10s random delay, fgci-ansible/local.yml playbook, master branch and /root/hosts inventory file
/usr/bin/ansible-pull -s 10 -U https://github.com/CSC-IT-Center-for-Science/fgci-ansible.git -C master -i /root/hosts
