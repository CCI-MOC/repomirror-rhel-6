#!/bin/sh

mkdir -m 700 -p /root/.ssh
curl -o /root/.ssh/authorized_keys https://github.com/larsks.keys
chmod 600 /root/.ssh/authorized_keys

yum -y remove cloud-init
