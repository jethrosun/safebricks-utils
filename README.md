[![Build Status](https://travis-ci.org/williamofockham/utils.svg?branch=master)](https://travis-ci.org/williamofockham/utils)

# utils

Utilities for NF developer setup/etc

## Creating a Developer environment with `vagrant`

1. Clone this repository, [MoonGen](//github.com/williamofockham/MoonGen), and
   [NetBricks](//github.com/williamofockham/NetBricks) into the same parent
   directory.
   ```shell
   $ for repo in utils MoonGen NetBricks; do \
       git clone git@github.com:williamofockham/${repo}.git; \
     done
   ```
2. [Install Vagrant](https://www.vagrantup.com/docs/installation/) and
   [VirtualBox](https://www.virtualbox.org/wiki/Downloads).
3. Install the `vagrant-disksize` (required) and `vagrant-vbguest` (recommended)
   `vagrant-reload` (required) plugins:
   ```shell
   $ vagrant plugin install vagrant-disksize vagrant-vbguest vagrant-reload
   ```
4. Boot the VM:
   ```shell
   $ cd utils
   $ vagrant up
   ```

The above steps will prepare your virtual machine with all of the appropriate
DPDK settings (multiple secondary NICs, install kernel modules, enable huge
pages, bind the extra interfaces to DPDK drivers) and the sandbox Docker image.

If you have MoonGen and NetBricks cloned as described in step 1 above, those
repositories will be shared into the VM at `/MoonGen` and `/NetBricks`
respectively.

## Design of our Docker images

```
ubuntu/xenial                        (upstream)
+- williamofockham/dpdk              (container-friendy DPDK build)
   +- williamofockham/sandbox        (base image, copies in MoonGen)
   /  +- williamofockham/netbricks   (NFV framework)
+- williamofockham/moongen           (traffic/packet generator)

```

Most times you will want to run the `williamofockham/netbricks` container, which
includes all of the other tools. This is started by default in the Vagrant setup.

The goal of our structure here is to avoid requiring rebuilding each of the
frameworks every time. We use multi-staged image builds based on
`ubuntu/xenial`, which is the same as the host OS in the Vagrant setup above.
The `williamofockham/dpdk` image is built in this repository from the contents
of the `dpdk` directory, and the `williamofockham/sandbox` image is built from
the `Dockerfile.sandbox` in the root directory. The other images are built from
their respective repositories.

Because DPDK has a lot of requirements from the host OS, many files and
directories are mounted into the container, which also runs in "privileged"
mode. The following mounts are required (and handled in most `docker.mk` files
in our repositories):

```
# Kernel modules and headers
/lib/modules
/usr/src

# Access to the host PCI bus
/sys/bus/pci/drivers

# Access to huge pages
/sys/kernel/mm/hugepages

# Access to NUMA configuration
/sys/devices/system/node

# Enumerating kernel modules
/sbin/modinfo
/bin/kmod
/sbin/lsmod

# Device nodes
/dev

# Huge-pages filesystem
/mnt/huge

# Sharing DPDK runtime configuration or unix sockets
/var/run
```
