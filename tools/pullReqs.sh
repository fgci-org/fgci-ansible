#!/bin/sh
#
#

/usr/bin/ansible-galaxy install -r requirements.yml --force

# Update requirements_mirror.yml for ansible-pull-script
ansible-playbook install.yml --tags=fgci-install
