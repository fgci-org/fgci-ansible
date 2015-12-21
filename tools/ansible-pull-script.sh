#!/bin/bash
# This file is created with ansible-role-fgci-install on the install node
#
# It is a script to run ansible-pull on an FGCI compute node
# It is first grabbed with curl during kickstart
# It's initially set to execute every 15 minutes
# Local.yml itself changes cron interval after execution.

# writes to syslog and stderr with tag ansible-pull
loggercmd="/usr/bin/logger -s -t ansible-pull"
export http_proxy="http://10.1.1.4:3128"
export https_proxy=$http_proxy
export no_proxy="localhost,10.1.1.2,raw.githubusercontent.com"
# Setup the ansible-pull fgci work dir
mkdir -p /root/.ansible/pull/$HOSTNAME
cd /root/.ansible/pull/$HOSTNAME

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

# Mirror in the group_vars - they are copied to install node's www with the fgci-install tag and role for install node.
# Wget assumes we are in $HOME/.ansible/pull/$HOSTNAME when running
/usr/bin/wget --random-wait 5 --no-host-directories --mirror --accept=example,yml,fgci-default-packages http://10.1.1.2/group_vars

# Install all the ansible role dependencies
/usr/bin/ansible-galaxy install -r requirements.yml -f -i
if [ "$?" != 0 ]; then
        $loggercmd "error: installing ansible requirements rc=$?"
fi

# Get the ansible hosts file 
/usr/bin/curl http://10.1.1.2/hosts > /root/hosts
if [ "$?" != 0 ]; then
        $loggercmd "error: curling http://10.1.1.2/hosts rc=$?"
fi

# customizable random delay in seconds, fgci-ansible/local.yml playbook, master branch and /root/hosts inventory file
/usr/bin/ansible-pull -s 10 -U https://github.com/CSC-IT-Center-for-Science/fgci-ansible.git -C {{ ansible_pull_branch }} -i /root/hosts
$loggercmd "info: ansible-pull -s 10 -U https://github.com/CSC-IT-Center-for-Science/fgci-ansible.git -C {{ ansible_pull_branch }} -i /root/hosts exited with rc=$?"

# Grab the latest ansible-pull-script.sh
/usr/bin/ansible -i /root/hosts -m get_url -a "url=http://10.1.1.2/ansible-pull-script.sh dest=/usr/local/bin/" localhost
if [ "$?" != 0 ]; then
        $loggercmd "error: ansible -i /root/hosts -m get_url -a 'url=http://10.1.1.2/ansible-pull-script.sh dest=/usr/local/bin/' localhost failed with rc=$?"
fi
