#!/bin/bash

if [ ! -f /etc/libvirt/qemu/{{ ansible_hostname }}.xml ]; then

virt-install \
  --name {{ ansible_hostname }} \
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
  --initrd-inject '{{ kickstart_tempdir }}/{{ ansible_hostname }}.ks' \
  --extra-args 'ks=file:/{{ ansible_hostname }}.ks console=ttyS0,115200n8' \
  --console pty,target_type=serial
fi
