dhcp_server
===========

This role installs and configures a DHCP server.

Requirements
------------

This role requires Ansible 1.4 or higher and platform requirements are listed
in the metadata file.

Role Variables
--------------

The variables that can be passed to this role and a brief description about
them are as follows. These are all based on the configuration variables of the
DHCP server configuration.

    # Basic configuration information
    dhcp_interfaces: eth0
    dhcp_common_domain: example.org
    dhcp_common_nameservers: ns1.example.org, ns2.example.org
    dhcp_common_default_lease_time: 600
    dhcp_common_max_lease_time: 7200
    dhcp_common_ddns_update_style: none
    dhcp_common_authoritative: true
    dhcp_common_log_facility: local7
    dhcp_common_options:
    - opt66 code 66 = string
    dhcp_common_parameters:
    - filename "pxelinux.0"

    # Subnet configuration
    dhcp_subnets:
    # Required variables example
    - base: 192.168.1.0
      netmask: 255.255.255.0
    # Full list of possibilities
    - base: 192.168.10.0
      netmask: 255.255.255.0
      range_start: 192.168.10.150
      range_end: 192.168.10.200
      routers: 192.168.10.1
      broadcast_address: 192.168.10.255
      domain_nameservers: 192.168.10.1, 192.168.10.2
      domain_name: example.org
      ntp_servers: pool.ntp.org
      default_lease_time: 3600
      max_lease_time: 7200
      pools:
      - range_start: 192.168.100.10
        range_end: 192.168.100.20
        rule: 'allow members of "foo"'
        parameters:
        - filename "pxelinux.0"
      - range_start: 192.168.110.10
        range_end: 192.168.110.20
        rule: 'deny members of "foo"'
      parameters:
      - filename "pxelinux.0"

    # Fixed lease configuration
    dhcp_hosts:
    - name: local-server
      mac_address: "00:11:22:33:44:55"
      fixed_address: 192.168.10.10
      default_lease_time: 43200
      max_lease_time: 86400
      parameters:
      - filename "pxelinux.0"

    # Class configuration
    dhcp_classes:
    - name: foo
      rule: 'match if substring (option vendor-class-identifier, 0, 4) = "SUNW"'
    - name: CiscoSPA
      rule: 'match if (( substring (option vendor-class-identifier,0,13) = "Cisco SPA504G" ) or
             ( substring (option vendor-class-identifier,0,13) = "Cisco SPA303G" ))'
      options:
      - opt: 'opt66 "http://utils.opentech.local/cisco/cisco.php?mac=$MAU"'
      - opt: 'time-offset 21600'

    # Shared network configurations
    dhcp_shared_networks:
    - name: shared-net
      subnets:
      - base: 192.168.100.0
        netmask: 255.255.255.0
        routers: 192.168.10.1
      parameters:
      - filename "pxelinux.0"
      pools:
      - range_start: 192.168.100.10
        range_end: 192.168.100.20
        rule: 'allow members of "foo"'
        parameters:
        - filename "pxelinux.0"
      - range_start: 192.168.110.10
        range_end: 192.168.110.20
        rule: 'deny members of "foo"'

    # Custom if else clause
      dhcp_ifelse:
      - condition: 'exists user-class and option user-class = "iPXE"'
        val: 'filename "http://my.web.server/real_boot_script.php";'
        else:
          - val: 'filename "pxeboot.0";'
          - val: 'filename "pxeboot.1";'

Examples
========

1) Install DHCP server on interface eth0 with one simple subnet:

    - hosts: all
      roles:
      - role: dhcp_server
        dhcp_interfaces: eth0
        dhcp_common_domain: example.org
        dhcp_common_nameservers: ns1.example.org, ns2.example.org
        dhcp_common_default_lease_time: 600
        dhcp_common_max_lease_time: 7200
        dhcp_common_ddns_update_style: none
        dhcp_common_authoritative: true
        dhcp_common_log_facility: local7
        dhcp_subnets:
        - base: 192.168.10.0
          netmask: 255.255.255.0
          range_start: 192.168.10.150
          range_end: 192.168.10.200
          routers: 192.168.10.1


Dependencies
------------

None

License
-------

BSD

Author Information
------------------

Philippe Dellaert


