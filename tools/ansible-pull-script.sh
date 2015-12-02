#!/bin/bash

# setup the ansible-pull fgci work dir
mkdir -p $HOME/.ansible/pull/$HOSTNAME
cd $HOME/.ansible/pull/$HOSTNAME
if [ ! -d ".git" ]; then
git clone https://github.com/CSC-IT-Center-for-Science/fgci-ansible.git .
else
git pull
fi
# install all the dependencies
ansible-galaxy install -r requirements.yml -f -i

# use -s to add a random sleep
ansible-pull -U https://github.com/CSC-IT-Center-for-Science/fgci-ansible.git -C ansible-pull -i hosts
