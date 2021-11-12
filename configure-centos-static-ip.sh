#!/bin/sh

echo 'Setting static IP address for Hyper-V...'

cat << EOF > /etc/sysconfig/network-scripts/ifcfg-eth0
DEVICE=eth0
BOOTPROTO=none
ONBOOT=yes
IPADDR=192.168.33.10
PREFIX=24
GATEWAY=192.168.33.1
EOF

# Be sure NOT to execute "systemctl restart network" here, so the changes take
# effect on reboot instead of immediately, which would disconnect the provisioner.

