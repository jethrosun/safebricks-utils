# Docker-specific williamofockham/utils
# =====================================
# Expectation for docker commands is to work with hub.docker.com; so
# YOU MUST BE Docker LOGGED-IN.

NAMESPACE = williamofockham

BASE_DIR = $(shell pwd)

DPDK_IMG = dpdk
DPDK_DEVBIND_IMG = dpdk-devbind
DPDK_BASE_DIR = $(BASE_DIR)/dpdk
DPDK_DOCKERFILE = $(DPDK_BASE_DIR)/Dockerfile
DPDK_VERSION = 17.08.1

SANDBOX_IMG = sandbox
SANDBOX_DOCKERFILE = Dockerfile
RUST_VERSION = nightly-2018-12-01

.PHONY: build build-dpdk build-dpdk-devbind build-sandbox \
		push push-dpdk push-dpdk-devbind push-sandbox \
		pull pull-dpdk pull-dpdk-devbind pull-sandbox \
		publish rmi

build-dpdk:
	@docker build -f $(DPDK_DOCKERFILE) --target $(DPDK_IMG) \
	-t $(NAMESPACE)/$(DPDK_IMG):$(DPDK_VERSION) $(DPDK_BASE_DIR)

build-dpdk-devbind:
	@docker build -f $(DPDK_DOCKERFILE) --target $(DPDK_DEVBIND_IMG) \
	-t $(NAMESPACE)/$(DPDK_DEVBIND_IMG):$(DPDK_VERSION) $(DPDK_BASE_DIR)

build-sandbox:
	@docker build -f $(SANDBOX_DOCKERFILE) \
	-t $(NAMESPACE)/$(SANDBOX_IMG):$(RUST_VERSION) $(shell pwd)

build: build-dpdk build-dpdk-devbind build-sandbox

push-dpdk:
	@docker push $(NAMESPACE)/$(DPDK_IMG):$(DPDK_VERSION)

push-dpdk-devbind:
	@docker push $(NAMESPACE)/$(DPDK_DEVBIND_IMG):$(DPDK_VERSION)

push-sandbox:
	@docker push $(NAMESPACE)/$(SANDBOX_IMG):$(RUST_VERSION)

push: push-dpdk push-dpdk-devbind push-sandbox

pull-dpdk:
	@docker pull $(NAMESPACE)/$(DPDK_IMG):$(DPDK_VERSION)

pull-dpdk-devbind:
	@docker pull $(NAMESPACE)/$(DPDK_DEVBIND_IMG):$(DPDK_VERSION)

pull-sandbox:
	@docker pull $(NAMESPACE)/$(SANDBOX_IMG):$(RUST_VERSION)

pull: pull-dpdk pull-dpdk-devbind pull-sandbox

publish: build push

rmi:
	@docker rmi $(NAMESPACE)/$(DPDK_IMG):$(DPDK_VERSION) \
	$(NAMESPACE)/$(DPDK_DEVBIND_IMG):$(DPDK_VERSION) \
	$(NAMESPACE)/$(SANDBOX_IMG):$(RUST_VERSION)

run:
	@docker run -it --rm --privileged --network=host \
		-w /opt \
		-v /lib/modules:/lib/modules \
		-v /usr/src:/usr/src \
		-v /dev/hugepages:/dev/hugepages \
		-v $(BASE_DIR)/NetBricks:/opt/netbricks \
		-v $(BASE_DIR)/MoonGen:/opt/moongen \
		$(SANDBOX) /bin/bash
