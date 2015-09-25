# fgci-ansible
Collection of the Finnish Grid and Cloud Infrastructure Ansible playbooks

[![Build Status](https://travis-ci.org/CSC-IT-Center-for-Science/fgci-ansible.svg?branch=master)](https://travis-ci.org/CSC-IT-Center-for-Science/fgci-ansible)

# Usage:
 - make a hosts file
 - install ansible repos with: <pre>ansible-galaxy install -r requirements.yml</pre>

# Running:

Basic Usage Example, more details on https://confluence.csc.fi/display/FGCI/Architecture+and+Software+Stack:
<pre>
ansible-playbook -i hosts site.yml --tags user
ansible-playbook -u ssh-user -i hosts site.yml --tags user
</pre>

# TODO

This playbook is very much a work in progress.

https://confluence.csc.fi/display/FGCI/Ansible+Tasks
