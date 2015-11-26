#!/bin/bash

if [ ! -f /etc/libvirt/qemu/{{ inventory_hostname.split('.').0 }}.xml ]; then

virt-install \
  --name {{ inventory_hostname.split('.').0 }} \
  --os-variant rhel7 \
  --cpu host-model \
  --vcpus {{ vcpus }} \
  --ram {{ ram }} \
{% for disk in disks %}
  --disk pool={{ disk.pool }},cache=writethrough,device=disk,bus=virtio,size={{ disk.size }},format=raw \
{% endfor %}
{% for bridge in bridges %}
  --network bridge={{ bridge }},model=virtio \
{% endfor %}
  --connect qemu:///system \
  --location {{ location }} \
  --graphics=vnc,keymap="fi" \
  --wait 20 \
  --initrd-inject '{{ kickstart_tempdir }}/{{ inventory_hostname.split('.').0 }}.ks' \
  --extra-args 'ks=file:/{{ inventory_hostname.split('.').0 }}.ks console=ttyS0,115200n8' \
  --console pty,target_type=serial
fi
