#!/bin/bash

sudo docker build --rm -t local/c7-systemd -f tests/Dockerfile .
sudo docker run -it --privileged=true --rm=false -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v `pwd`:/fgci-ansible:rw local/c7-systemd /bin/bash -c "/fgci-ansible/tests/test-in-docker-image.sh ${OS_TYPE} ${OS_VERSION} ${ANSIBLE_VERSION}"
