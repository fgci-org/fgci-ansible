#!/bin/bash

if [ ! -f /etc/libvirt/qemu/{{ inventory_hostname }}.xml ]; then

virt-install \
  --name {{ inventory_hostname }} \
  --os-variant rhel7 \
  --cpu host-model \
  --vcpus {{ vcpus }} \
  --ram {{ ram }} \
{% for disk in disks %}
  --disk path={{ disk.path }},cache=writethrough,device=disk,bus=virtio,size={{ disk.size }},format=raw \
{% endfor %}
{% for bridge in bridges %}
  --network bridge={{ bridge }},model=virtio \
{% endfor %}
  --connect qemu:///system \
  --location '{{ location }}' \
  --graphics vnc \
  --noautoconsole \
  --wait 10 \
  --initrd-inject '{{ kickstart_tempdir }}/{{ inventory_hostname }}.ks' \
  --extra-args 'ks=file:/{{ inventory_hostname }}.ks console=ttyS0,115200n8' \
  --console pty,target_type=serial
fi
