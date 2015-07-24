dnsmasq\_proxy
==============

This Ansible role is meant to provide painless setup of an internal
network DNS server that also acts as a proxy/cache for worldwide DNS lookups.

This is a very early release. At the moment, all it does is ensure that the
`dnsmasq` package is installed on systems that use `yum` or `pkgin` for their
package management.  In practical terms, that means it should be compatible
with all RedHat-class and SmartOS (Joyent) systems.

Requirements
------------

See above

Role Variables
--------------

Variable names start with `dnsmasq_` and are harmonized with variable names
from Bert Van Vreckem's dnsmasq role (`bert.vanvreckem.dnsmasq`).

* `dnsmasq_addn_hosts` (*Optional*) -- Read host info from this hosts file;
  /etc/hosts will also be read unless `dnsmasq_no_hosts` is set.
* `dnsmasq_addresses` (*Optional*) -- Addresses for specific hostnames that
  dnsmasq should return.
* `dnsmasq_bogus_nxdomain` (*Optional*) -- When set, if this IP address is
  found in results, return an NXDOMAIN response instead.  This is useful if you
  are using a provider that always returns the same IP address for not-found
  DNS queries, e.g. to serve up a web page of advertising instead. (See
  ["Domain hijacking" on Wikipedia](https://en.wikipedia.org/wiki/DNS_hijacking).)
* `dnsmasq_bogus_priv` (*Optional*) -- Never forward addresses in the
  non-routed address spaces.
* `dnsmasq_domain` (*Optional*) -- Sets the internal domain name served by
  dnsmasq; this has implications both for DNS and DHCP service (see the dnsmasq
  docs for more).
* `dnsmasq_domain_needed` (*Optional*) -- Never forward plain names (without a
  dot or domain part)
* `dnsmasq_expand_hosts` (*Optional*) -- When set, add the value of `dnsmasq_domain`
  to simple, non-dotted, non-qualified names in hosts files.
* `dnsmasq_external_servers` (*Optional*) -- Upstream DNS servers that can
  answer global requests.
* `dnsmasq_forward_servers` (*Optional*) -- Specific domains for which DNS requests
  should be forwarded, and the addresses of the DNS servers to forward them to.
* `dnsmasq_local_ttl` (*Default value:* 0) -- Time-To-Live value (seconds) for
  responses coming from hosts files and the DHCP lease file. A value of 0
  effectively means "do not cache."
* `dnsmasq_log_dhcp` (*Optional*) -- Log lots of extra information about DHCP
  transactions, for debugging.
* `dnsmasq_log_queries` (*Optional*) -- Log all DNS queries coming through dnsmasq,
  for debugging.
* `dnsmasq_no_dhcp` (*Optional*) -- Disable DHCP and TFTP completely.
* `dnsmasq_no_hosts` (*Optional*) -- Do not read host address info from /etc/hosts.
* `dnsmasq_no_resolv` (*Optional*) -- Do not attempt to get DNS server info
  from /etc/resolv.conf.
* `dnsmasq_port` (*Default value:* 53) -- Listen on this specific port for DNS
  requests.  If set to 0, DNS services will be disabled completely
  (independently of DHCP and TFTP).


Dependencies
------------

None

Example Playbook
----------------

```yaml
- hosts: internal_dns_servers
  roles:
     - { role: L2G.dnsmasq_proxy }
```

License
-------

Creative Commons Attribution 4.0 International (http://creativecommons.org/licenses/by/4.0/)

Author Information
------------------

Larry "Lawrence Leonard" Gilbert, larry@L2G.to, https://github.com/L2G, 844-L2G-GEEK

Notes in the dnsmasq.conf file come from the example file provided with dnsmasq
and have been edited to varying degrees by Larry Gilbert.
