# fgci-ansible
Collection of the Finnish Grid and Cloud Infrastructure Ansible playbooks

# Usage:
 - make a hosts file
 - install ansible repos with: <pre>ansible-galaxy install -r requirements.yml</pre>

# TODO
## Install node TODO:

Port changes previously done with kickstart to ansible: http://pulse.fgi.csc.fi/install-ks.cfg

 - apachehttpd
 - dhcp/tftp?
 - DNS/named
 - install packages
 - metrics/ganglia
 - network-config 
  - onboot/peerdns
  - disable NetworkManager
 - NFS 
  - mounting
  - setup / domain etc
 - rdma
 - slurm
  - slurm/mysqld
  - slurm/munge
  - slurmdbd
  - slurm health/check
 - squid-proxy
 - sshd
 - user administration - 
  - add local groups
  - add local users
  - add authorized key to users
  - only allow admin group ssh
 - yum autoupdate
 - ypserv/NIS

## Idea / Possible Additions

Other things from https://confluence.csc.fi/display/fgi/Cluster+installation+instructions

 - centralized logging
 - firewall
  - remove firewalld and install iptables-services?
 - disk health / administration tools
  - megacli for if perc controller from Dell
 - grid certificates
 - iLO/iDRAC/IPMI & BIOS
 - monitoring
 - mail changes - /etc/aliases
 - setup new /etc/cluster directory
 - stop&disable unwanted services
 - switch configs ethernet/infiniband
 - user management
  - adding 
  - extending
