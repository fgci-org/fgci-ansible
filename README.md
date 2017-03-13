# fgci-ansible
Collection of the Finnish Grid and Cloud Infrastructure Ansible playbooks

Used in production in >9 uniform HPC clusters.

<a href="https://research.csc.fi/fgci"><img src="meta/FGCI-logo.jpg"></a>

[![Build Status](https://travis-ci.org/CSC-IT-Center-for-Science/fgci-ansible.svg?branch=master)](https://travis-ci.org/CSC-IT-Center-for-Science/fgci-ansible) [![Stories in Ready](https://badge.waffle.io/CSC-IT-Center-for-Science/fgci-ansible.png?label=ready&title=Ready)](https://waffle.io/CSC-IT-Center-for-Science/fgci-ansible)

[Build Status](https://travis-ci.org/CSC-IT-Center-for-Science/fgci-ansible) [Backlog](https://waffle.io/CSC-IT-Center-for-Science/fgci-ansible)

## Physical Hardware:
 - The clusters are made with the same basic building blocks:
   - One admin node (hypervisor for one grid (middleware) and one install node (slurm services, git mirror, pxe/dhcp))
   - One login node
   - One NFS node for two shared filesystems ( /home and /scratch )
   - X Compute ( and Y GPU nodes )
   - Ethernet and Infiniband networks

## Software Stack:
 - [Ansible](http://ansible.com/) (ansible-pull is used on the compute nodes, push mode on the rest)
 - CentOS 7
 - [CVMFS](https://cernvm.cern.ch/portal/filesystem) for software distribution á la modules
 - [Nordugrid ARC](http://www.nordugrid.org/arc/)
 - [SLURM](https://slurm.schedmd.com/)

# Minimally Descriptive Configuration:
 - clone this repo
 - make an ansible inventory/hosts file (there is an example file in the examples/ dir)
 - install required ansible roles from external repositories with: <pre>ansible-galaxy install -r requirements.yml</pre> or <pre>sh tools/pullReqs.sh</pre>
 - Copy dir examples/group_vars to the repository root dir, ( fgci-ansible/group_vars )
 - Edit group_vars files with your system configuration parameters

## Running:

Basic Usage Example, more details on https://confluence.csc.fi/display/FGCI/FGCI+Cluster+deployment+and+installation+guide (restricted access):
<pre>
ansible-playbook -i hosts site.yml --tags user
ansible-playbook -u ssh-user -i hosts site.yml --tags user --diff
</pre>

## Backlog

For our backlog checkout the waffle iron: https://waffle.io/CSC-IT-Center-for-Science/fgci-ansible

## Contributions, Workflow and role preferences

<a href="CONTRIBUTION.MD">CONTRIBUTION.MD</a>

## Bug Reports and Pull or Feature Requests 

Please submit these to the individual Github repositories or normal CSC service desk. If they are not in CSC's organization in github submitting to this repo (fgci-ansible) is OK.

There is a list of where the ansible roles come from in the <a href="requirements.yml">requirements.yml</a> file.

## License

MIT
