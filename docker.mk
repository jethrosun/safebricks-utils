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

ifeq ($(CONTAINER),$(DPDK_CONTAINER))
  DOCKERFILE=dpdk/Dockerfile
endif

LINUX_HEADERS = -v /lib/modules:/lib/modules
MOUNTS = $(LINUX_HEADERS) \
         -v /sys/bus/pci/drivers:/sys/bus/pci/drivers \
         -v /sys/kernel/mm/hugepages:/sys/kernel/mm/hugepages \
         -v /sys/devices/system/node:/sys/devices/system/node \
         -v /sbin/modinfo:/sbin/modinfo \
         -v /bin/kmod:/bin/kmod \
         -v /sbin/lsmod:/sbin/lsmod \
         -v /dev:/dev \
         -v /var/run:/var/run

.PHONY: build build-fresh run run-reg run-dpdk run-reg-dpdk tag push pull image \
        image-fresh rmi rmi-registry vm vm-dpdk

build:
	@docker build -f $(DOCKERFILE) -t $(CONTAINER):$(TAG) \
	 $(BASE_DIR)

build-fresh:
	@docker build --no-cache -f $(DOCKERFILE) -t $(CONTAINER):$(TAG) \
	$(BASE_DIR)

run:
	@docker run --name $(CONTAINER) -it --rm --privileged --pid='host' \
	$(MOUNTS) -v $(BASE_DIR):/opt/$(CONTAINER) $(CONTAINER):$(TAG)

run-reg:
	@docker run --name $(CONTAINER) -it --rm --privileged --pid='host' \
	$(MOUNTS) -v $(BASE_DIR):/opt/$(CONTAINER) $(PROJECT)/$(CONTAINER):$(TAG)

run-dpdk:
	@docker run --name $(DPDK_CONTAINER) -it --rm --privileged --pid='host' \
	$(MOUNTS) $(DPDK_CONTAINER):$(TAG)

run-reg-dpdk:
	@docker run --name $(DPDK_CONTAINER) -it --rm --privileged --pid='host' \
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
