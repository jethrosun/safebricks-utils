#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

# Install dependencies
sudo apt-get -q update
sudo apt-get -q install -y cmake mg make git linux-headers-$(uname -r) linux-image-extra-$(uname -r)

# Allocate 1024 hugepages of 2 MB
# Change can be validated by executing 'cat /proc/meminfo | grep Huge'
echo 1024 > /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages

# Allocate 1024 hugepages of 2 MB at startup
echo "vm.nr_hugepages = 1024" >> /etc/sysctl.conf

# Set /mnt/huge
mkdir -p /mnt/huge && mount -t hugetlbfs nodev /mnt/huge
echo "hugetlbfs /mnt/huge hugetlbfs rw,mode=0777 0 0" >> /etc/fstab

# Install the uio_pci_generic driver
modprobe uio_pci_generic

# Load modules at boot
echo "uio" >> /etc/modules
echo "uio_pci_generic" >> /etc/modules

# Ensure the following `proc` variables are set correctly
echo "net.ipv6.conf.all.disable_ipv6 = 0
net.ipv6.conf.default.forwarding = 1
net.ipv6.conf.default.accept_source_route = 1
net.ipv6.conf.default.accept_ra = 2
net.ipv6.conf.all.forwarding = 1
net.ipv6.conf.all.accept_source_route = 1
net.ipv6.conf.all.accept_ra = 2
net.ipv6.conf.all.seg6_enabled = 1
net.ipv6.conf.default.seg6_enabled = 1" >> /etc/sysctl.conf

sysctl -e -p
