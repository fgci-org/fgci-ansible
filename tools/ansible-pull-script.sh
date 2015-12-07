#!/bin/bash
# This file is created with ansible-role-fgci-install on the install node
#
# It is a script to run ansible-pull on an FGCI compute node
# It is first grabbed with curl during kickstart
# It's initially set to execute every 15 minutes
# Local.yml itself changes cron interval after execution.

# writes to syslog and stderr with tag ansible-pull
loggercmd="/usr/bin/logger -s -t ansible-pull"
HTTP_PROXY="{{ http_proxy }}"
# Setup the ansible-pull fgci work dir
mkdir -p $HOME/.ansible/pull/$HOSTNAME
cd $HOME/.ansible/pull/$HOSTNAME

# Clone or update the fgci-ansible repo
if [ ! -d ".git" ]; then
/usr/bin/git clone https://github.com/CSC-IT-Center-for-Science/fgci-ansible.git .
if [ "$?" != 0 ]; then
        $loggercmd "error: with 'git clone https://github.com/CSC-IT-Center-for-Science/fgci-ansible.git .' PWD=$PWD rc=$?"
fi
else
# If the .git directory exists then only run git pull
/usr/bin/git pull
if [ "$?" != 0 ]; then
        $loggercmd "error: git pull in PWD=$PWD rc=$?"
fi
fi

# Install all the ansible role dependencies
/usr/bin/ansible-galaxy install -r requirements.yml -f -i
if [ "$?" != 0 ]; then
        $loggercmd "error: installing ansible requirements rc=$?"
fi

# Get the ansible hosts file 
/usr/bin/curl http://{{ kickstart_server_ip }}/hosts > /root/hosts
if [ "$?" != 0 ]; then
        $loggercmd "error: curling http://{{ kickstart_server_ip }}/hosts rc=$?"
fi

# customizable random delay in seconds, fgci-ansible/local.yml playbook, master branch and /root/hosts inventory file
/usr/bin/ansible-pull -s {{ ansible_pull_sleep }} -U https://github.com/CSC-IT-Center-for-Science/fgci-ansible.git -C master -i /root/hosts
$loggercmd "info: ansible-pull -s {{ ansible_pull_sleep }} -U https://github.com/CSC-IT-Center-for-Science/fgci-ansible.git -C master -i /root/hosts exited with rc=$?"

# Grab the latest ansible-pull-script.sh
/usr/bin/ansible -i /root/hosts -m get_url -a "url=http://{{ kickstart_server_ip }}/ansible-pull-script.sh dest=/usr/local/bin/" localhost
if [ "$?" != 0 ]; then
        $loggercmd "error: ansible -i /root/hosts -m get_url -a 'url=http://{{ kickstart_server_ip }}/ansible-pull-script.sh dest=/usr/local/bin/' localhost failed with rc=$?"
fi
