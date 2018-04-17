# -*- mode: ruby -*-

# Vagrant file API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

def path_exists?(path)
  File.directory?(path)
end

$dimage = ENV.fetch("DIMAGE", "netbricks")
$dtag = ENV.fetch("DTAG", "latest")
$dproject = ENV.fetch("DPROJECT", "williamofockham")
$nbpath = ENV.fetch("NBPATH", "../NetBricks")
$mgpath = ENV.fetch("MGPATH", "../MoonGen")
$dpdk_driver = ENV.fetch("DPDK_DRIVER", "uio_pci_generic")
$dpdk_devices = ENV.fetch("DPDK_DEVICES", "0000:00:08.0 0000:00:09.0")

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at https://docs.vagrantup.com.
  config.vm.box = "ubuntu/xenial64"
  config.disksize.size = "30GB"
  config.vm.synced_folder ".", "/vagrant", disabled: false
  if path_exists?($nbpath)
    config.vm.synced_folder $nbpath, "/NetBricks", disabled: false
  end
  if path_exists?($mgpath)
    config.vm.synced_folder $mgpath, "/MoonGen", disabled: false
  end

  # Create a private network, which allows host-only access to the machine using a
  # specific IP. This option is needed because DPDK takes over the NIC.
  config.vm.network "private_network", ip: "10.1.2.2", nic_type: "virtio"
  config.vm.network "private_network", ip: "10.1.2.3", nic_type: "virtio"

  # Setup the VM for DPDK, including binding the extra interface via the fetched
  # container
  config.vm.provision "shell", path: "vm-setup.sh"

  # Pull and run (then remove) our image in order to do the devbind
  config.vm.provision "docker" do |d|
    d.pull_images "#{$dproject}/#{$dimage}:#{$dtag}"
    d.run "#{$dproject}/#{$dimage}:#{$dtag}",
          auto_assign_name: false,
          args: %w(--name=$dimage
                   --rm
                   --privileged
                   --pid=host
                   --network=host
                   -v /lib/modules:/lib/modules
                   -v /usr/src:/usr/src
                   -v /sys/bus/pci/drivers:/sys/bus/pci/drivers
                   -v /sys/kernel/mm/hugepages:/sys/kernel/mm/hugepages
                   -v /sys/devices/system/node:/sys/devices/system/node
                   -v /sbin/modinfo:/sbin/modinfo
                   -v /bin/kmod:/bin/kmod
                   -v /sbin/lsmod:/sbin/lsmod
                   -v /dev:/dev
                   -v /mnt/huge:/mnt/huge
                   -v /var/run:/var/run).join(" "),
          restart: "no",
          daemonize: true,
          cmd: "/bin/bash -c '/dpdk/usertools/dpdk-devbind.py --force -b #{$dpdk_driver} #{$dpdk_devices}'"
  end

  # VirtualBox-specific configuration
  config.vm.provider "virtualbox" do |vb|
    # Set machine name, memory and CPU limits
    vb.name = "ubuntu-xenial-williamofockham"
    vb.memory = 4096
    vb.cpus = 4

    # Configure VirtualBox to enable passthrough of SSE 4.1 and SSE 4.2 instructions,
    # according to this: https://www.virtualbox.org/manual/ch09.html#sse412passthrough
    # This step is fundamental otherwise DPDK won't build. It is possible to verify in
    # the guest OS that these changes took effect by running `cat /proc/cpuinfo` and
    # checking that `sse4_1` and `sse4_2` are listed among the CPU flags.
    vb.customize ["setextradata", :id, "VBoxInternal/CPUM/SSE4.1", "1"]
    vb.customize ["setextradata", :id, "VBoxInternal/CPUM/SSE4.2", "1"]

    # Allow promiscuous mode for host-only adapter
    vb.customize ["modifyvm", :id, "--nicpromisc2", "allow-all"]
  end
end
