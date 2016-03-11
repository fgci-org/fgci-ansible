# fgci-ansible
Collection of the Finnish Grid and Cloud Infrastructure Ansible playbooks

[![Build Status](https://travis-ci.org/CSC-IT-Center-for-Science/fgci-ansible.svg?branch=master)](https://travis-ci.org/CSC-IT-Center-for-Science/fgci-ansible) [![Stories in Ready](https://badge.waffle.io/CSC-IT-Center-for-Science/fgci-ansible.png?label=ready&title=Ready)](https://waffle.io/CSC-IT-Center-for-Science/fgci-ansible)

# Usage:
 - make a hosts file (you can use template file in examples dir)
 - install ansible repos with: <pre>ansible-galaxy install -r requirements.yml</pre> or <pre>sh tools/pullReqs.sh</pre>
 - Copy dir examples/group_vars to the repository root dir
 - on group_vars/ change file names from .example to .yml
 - Edit group_vars files with your system configuration parameters

# Running:

Basic Usage Example, more details on https://confluence.csc.fi/display/FGCI/FGCI+Cluster+deployment+and+installation+guide:
<pre>
ansible-playbook -i hosts site.yml --tags user
ansible-playbook -u ssh-user -i hosts site.yml --tags user
</pre>

# TODO

This playbook is very much a work in progress.

