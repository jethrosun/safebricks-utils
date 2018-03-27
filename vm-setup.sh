#!/bin/bash

# Allocate 1024 hugepages of 2 MB
# Change can be validated by executing 'cat /proc/meminfo | grep Huge'
echo 1024 > /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages

# Allocate 1024 hugepages of 2 MB at startup
echo "vm.nr_hugepages = 1024" >> /etc/sysctl.conf

# Install the uio_pci_generic driver
apt-get install -y linux-image-extra-$(uname -r)
modprobe uio_pci_generic

# Load modules at boot
echo "uio" >> /etc/modules
echo "uio_pci_generic" >> /etc/modules

# Bind the extra network device
docker run \
       --privileged \
       --pid=host \
       --network=host \
       --rm \
       -v /lib/modules:/lib/modules \
       -v /sys/bus/pci/drivers:/sys/bus/pci/drivers \
       -v /sys/kernel/mm/hugepages:/sys/kernel/mm/hugepages \
       -v /sys/devices/system/node:/sys/devices/system/node \
       -v /sbin/modinfo:/sbin/modinfo \
       -v /bin/kmod:/bin/kmod \
       -v /sbin/lsmod:/sbin/lsmod \
       -v /dev:/dev \
       -v /var/run:/var/run \
       $1 \
       /bin/bash -c "usertools/dpdk-devbind.py --force -b uio_pci_generic 0000:00:08.0"

echo "cd /vagrant" >> /home/vagrant/.bashrc
