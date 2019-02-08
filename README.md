[![Build Status](https://travis-ci.org/williamofockham/utils.svg?branch=master)](https://travis-ci.org/williamofockham/utils)

# utils

Utilities for NF developer setup/etc

## Creating a Developer environment with `vagrant`

1. Clone this repository, [MoonGen](//github.com/williamofockham/MoonGen), and
   [NetBricks](//github.com/williamofockham/NetBricks) into the same parent
   directory.
   ```shell
   host$ for repo in utils MoonGen NetBricks; do \
           git clone git@github.com:williamofockham/${repo}.git; \
         done
   ```
2. [Install Vagrant](https://www.vagrantup.com/docs/installation/) and
   [VirtualBox](https://www.virtualbox.org/wiki/Downloads).
3. Install the `vagrant-disksize` (required) and `vagrant-vbguest` (recommended)
   `vagrant-reload` (required) plugins:
   ```shell
   host$ vagrant plugin install vagrant-disksize vagrant-vbguest vagrant-reload
   ```
4. Symlink the Vagrantfile into the parent directory.
   ```shell
   host$ ln -s utils/Vagrantfile
   ```
4. Boot the VM:
   ```shell
   host$ vagrant up
   ```

The above steps will prepare your virtual machine with all of the appropriate DPDK settings (multiple secondary NICs, install kernel modules, enable huge pages, bind the extra interfaces to DPDK drivers) and install [Containernet](https://containernet.github.io/).

If you have MoonGen and NetBricks cloned as described in step 1 above, those repositories will be shared into the VM at `/vagrant/MoonGen` and `/vagrant/NetBricks` respectively.

## Design of our Docker images

```
bitnami/minideb:stretch              (upstream)
+- williamofockham/dpdk              (container-friendy DPDK build)
   +- williamofockham/sandbox        (dev image for rust and ebpf)
+- williamofockham/dpdk-devbind      (device bind utility)
```

You can either build all the container images locally in Vagrant,

```shell
vagrant$ cd utils
vagrant$ make -f docker.mk build
```

Or pull them down from Docker Hub,

```shell
vagrant$ cd utils
vagrant$ make -f docker.mk pull
```

Then you can run the sandbox container from the root directory,

```shell
vagrant$ make -f utils/docker.mk run
```

NetBricks is shared into the container at `/opt/netbricks` and MoonGen is shared at `/opt/moongen`.

Because DPDK has a lot of requirements from the host OS, many files and directories are mounted into the container, which also runs in "privileged" mode with "host" networking. The following mounts are required and handled by the run command:

```
# Kernel modules for DPDK utilties such as dpdk-devbind.py
/lib/modules

# Kernel headers for bcc-tools
/usr/src

# Access to huge pages
/dev/hugepages
```

## Other Docker images

1. `williamofockham/consul-esm`, [Consul ESM](https://github.com/hashicorp/consul-esm) is a daemon to run alongside Consul in order to run health checks for external nodes and update the status of those health checks in the catalog.
