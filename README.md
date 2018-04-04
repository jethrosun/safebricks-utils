[![Build Status](https://travis-ci.org/williamofockham/utils.svg?branch=master)](https://travis-ci.org/williamofockham/utils)

# utils

Utilities for NF developer setup/etc

## Creating Docker host with `corectl` (Mac)

`corectl` is a tool for running [CoreOS](https://coreos.com) virtual
machines using OS/X's built-in hypervisor toolkit. To get started, be
sure you have Homebrew installed and then run these commands inside
the sandbox:

``` shell
$ brew update
$ make -f corectl.mk vm
```

This will, in order:

1. Install `corectl` via homebrew.
2. Start up the daemon that manages CoreOS virtual machines,
   `corectld`. At this step you will be asked for your password.
3. Download the latest `alpha` channel CoreOS image.
4. Create and format a persistent disk image in the current directory.
5. Boot the `williamofockham` VM with the persistent disk attached and
   configure Docker for local use with IPv6 enabled.

Once the VM is booted, you can interact with its Docker daemon with
the following:

``` shell
$ export DOCKER_HOST=tcp://$(corectl q -i williamofockham):2375
```

or

```shell
$ eval `make -f corectl.mk env`
```

and then
```
$ docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
```

There should be no containers listed. You are now ready to use Docker
for local development.

### Tweaking the CoreOS configuration

There are a number of environment variables you may change when invoking `make
-f corectl.mk` to change the functionality of the VM:

 * `COREOS_CHANNEL`: (default: `alpha`) You can choose `beta` or `stable` update
   channels for CoreOS.
 * `CORECTL_VOLUME_SIZE`: (default: `40GiB`) The size of the QCOW2 image that
   will be created to store the Docker host's container images and state.
 * `CORECTL_VM_NAME`: (default: `williamofockham`) The name of the CoreOS VM to be
   created.
 * `CORECTL_CPUS`: (default: `2`) The number CPU cores to allocate to the
   virtual machine.
 * `CORECTL_RAM`: (default: `4096`) The amount of RAM to allocate to the virtual
   machine, in megabytes.
 * `CORECTL_VOLUME`: (default: `williamofockham-docker.img.qcow2`) The filename of the
   QCOW2 image that will be created to store the Docker host's container images
   and state.
 * `CORECTL_INIT`: (default: `corectl/cloud-init.yaml`) A `cloud-init` file used
   to configure the virtual machine on startup.
 * `CORECTL_KERNEL_FLAGS`: (default: `hugepages=1024`) Boot arguments to the
   Linux kernel in the virtual machine, which you can use to enable, disable, or
   configure certain operating system features.

### SSH'ing and Destroying the vm

If you need to connect to the VM, for example to get the configured
IPv6 address, use `corectl ssh williamofockham`.

To shutdown and destroy the VM and its persistent storage, run `make
-f corectl.mk destroy`.

### Caveats

* `corectl` has not been updated recently and so it has not taken into
  account the latest signature key for validating CoreOS
  images. `corectl.mk` circumvents this by fetching the image manually
  into the appropriate directories and passes the `-o` (offline) flag
  when running VMs to bypass the built-in fetching behavior.
