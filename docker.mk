# Docker-specific williamofockham/utils
# =====================================
# Expectation for docker commands is to work with hub.docker.com; so
# YOU MUST BE Docker LOGGED-IN.

TAG ?= latest
PROJECT = williamofockham
DOCKERFILE ?= Dockerfile.sandbox

SANDBOX_CONTAINER = sandbox
SANDBOX_BASE_DIR ?= $(or $(shell pwd),~/williamofockham/utils)

DPDK_BASE_DIR ?= $(or $(shell pwd/utils),~/williamofockham/utils/dpdk)
DPDK_CONTAINER = dpdk

CONTAINER ?= $(SANDBOX_CONTAINER)
BASE_DIR ?= $(SANDBOX_BASE_DIR)

# Our Vagrant setup places MoonGen's repo @ /MoonGen
# This works off of being relative (../) to utils/sandbox.
MOONGEN_DIR ?= $(or $(basename $(dirname $(shell pwd)))/MoonGen,\
~/williamofockham/MoonGen)

FILES_TO_MOUNT := $(foreach f,$(filter-out build libmoon,\
$(notdir $(wildcard $(MOONGEN_DIR)/*))), -v $(MOONGEN_DIR)/$(f):/opt/moongen/$(f))
BASE_MOUNT := -v $(BASE_DIR):/opt/$(CONTAINER)

ifeq ($(CONTAINER),$(DPDK_CONTAINER))
  DOCKERFILE=dpdk/Dockerfile
endif

LINUX_HEADERS = -v /lib/modules:/lib/modules -v /usr/src:/usr/src
MOUNTS = $(LINUX_HEADERS) \
         -v /sys/bus/pci/drivers:/sys/bus/pci/drivers \
         -v /sys/kernel/mm/hugepages:/sys/kernel/mm/hugepages \
         -v /sys/devices/system/node:/sys/devices/system/node \
         -v /sbin/modinfo:/sbin/modinfo \
         -v /bin/kmod:/bin/kmod \
         -v /sbin/lsmod:/sbin/lsmod \
         -v /dev:/dev \
         -v /mnt/huge:/mnt/huge \
         -v /var/run:/var/run \
         $(BASE_MOUNT) \
         $(FILES_TO_MOUNT)


.PHONY: build build-fresh run run-reg run-dpdk run-reg-dpdk tag push pull image \
        image-fresh rmi rmi-registry vm vm-dpdk

build:
	@docker build -f $(DOCKERFILE) -t $(CONTAINER):$(TAG) \
	 $(BASE_DIR)

build-fresh:
	@docker build --no-cache -f $(DOCKERFILE) -t $(CONTAINER):$(TAG) \
	$(BASE_DIR)

run:
	@docker run --name $(CONTAINER) -it --rm --privileged \
	--pid='host' --network='host' \
	$(MOUNTS) $(CONTAINER):$(TAG)

run-reg:
	@docker run --name $(CONTAINER) -it --rm --privileged \
	--pid='host' --network='host' \
	$(MOUNTS) $(PROJECT)/$(CONTAINER):$(TAG)

run-dpdk:
	@docker run --name $(DPDK_CONTAINER) -it --rm --privileged \
	--pid='host' --network='host' \
	$(MOUNTS) $(DPDK_CONTAINER):$(TAG)

run-reg-dpdk:
	@docker run --name $(DPDK_CONTAINER) -it --rm --privileged \
	--pid='host' --network='host' \
	$(MOUNTS) $(PROJECT)/$(DPDK_CONTAINER):$(TAG)

tag:
	@docker tag $(CONTAINER) $(PROJECT)/$(CONTAINER):$(TAG)

push:
	@docker push $(PROJECT)/$(CONTAINER):$(TAG)

pull:
	@docker pull $(PROJECT)/$(CONTAINER):$(TAG)

image: build tag push

image-fresh: build-fresh tag push

rmi:
	@docker rmi $(CONTAINER):$(TAG)

rmi-registry:
	@docker rmi $(PROJECT)/$(CONTAINER):$(TAG)

vm:
	@vagrant up

vm-dpdk:
	@IMG=$(PROJECT)/dpdk:$(TAG) vagrant up
