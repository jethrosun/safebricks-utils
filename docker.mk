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
RUST_VERSION = nightly-2019-02-01

ESM_IMG = consul-esm
ESM_BASE_DIR = $(BASE_DIR)/consul-esm
ESM_DOCKERFILE = $(ESM_BASE_DIR)/Dockerfile
ESM_VERSION = 0.3.2

DIND_IMG = containernet-node
DIND_BASE_DIR = $(BASE_DIR)/dind
DIND_DOCKERFILE = $(DIND_BASE_DIR)/Dockerfile
DIND_VERSION = 1.23.2

.PHONY: build build-dpdk build-dpdk-devbind build-sandbox build-esm build-dind \
		push push-dpdk push-dpdk-devbind push-sandbox push-esm push-dind \
		pull pull-dpdk pull-dpdk-devbind pull-sandbox pull-esm pull-dind \
		publish rmi

build-dpdk:
	@docker build -f $(DPDK_DOCKERFILE) --target $(DPDK_IMG) \
		--build-arg DPDK_VERSION=${DPDK_VERSION} \
		-t $(NAMESPACE)/$(DPDK_IMG):$(DPDK_VERSION) $(DPDK_BASE_DIR)

build-dpdk-devbind:
	@docker build -f $(DPDK_DOCKERFILE) --target $(DPDK_DEVBIND_IMG) \
		--build-arg DPDK_VERSION=${DPDK_VERSION} \
		-t $(NAMESPACE)/$(DPDK_DEVBIND_IMG):$(DPDK_VERSION) $(DPDK_BASE_DIR)

build-sandbox:
	@docker build -f $(SANDBOX_DOCKERFILE) \
		--build-arg RUSTUP_TOOLCHAIN=${RUST_VERSION} \
		-t $(NAMESPACE)/$(SANDBOX_IMG):$(RUST_VERSION) $(shell pwd)

build-esm:
	@docker build -f $(ESM_DOCKERFILE) \
	--build-arg CONSUL_ESM=${ESM_VERSION} \
	-t $(NAMESPACE)/$(ESM_IMG):$(ESM_VERSION) $(ESM_BASE_DIR)

build-dind:
	@docker build -f $(DIND_DOCKERFILE) \
	--build-arg COMPOSE=${DIND_VERSION} \
	-t $(NAMESPACE)/$(DIND_IMG):$(DIND_VERSION) $(DIND_BASE_DIR)

build: build-dpdk build-dpdk-devbind build-sandbox build-esm build-dind

push-dpdk:
	@docker push $(NAMESPACE)/$(DPDK_IMG):$(DPDK_VERSION)

push-dpdk-devbind:
	@docker push $(NAMESPACE)/$(DPDK_DEVBIND_IMG):$(DPDK_VERSION)

push-sandbox:
	@docker push $(NAMESPACE)/$(SANDBOX_IMG):$(RUST_VERSION)

push-esm:
	@docker push $(NAMESPACE)/$(ESM_IMG):$(ESM_VERSION)

push-dind:
	@docker push $(NAMESPACE)/$(DIND_IMG):$(DIND_VERSION)

push: push-dpdk push-dpdk-devbind push-sandbox push-esm push-dind

pull-dpdk:
	@docker pull $(NAMESPACE)/$(DPDK_IMG):$(DPDK_VERSION)

pull-dpdk-devbind:
	@docker pull $(NAMESPACE)/$(DPDK_DEVBIND_IMG):$(DPDK_VERSION)

pull-sandbox:
	@docker pull $(NAMESPACE)/$(SANDBOX_IMG):$(RUST_VERSION)

pull-esm:
	@docker pull $(NAMESPACE)/$(ESM_IMG):$(ESM_VERSION)

pull-dind:
	@docker pull $(NAMESPACE)/$(DIND_IMG):$(DIND_VERSION)

pull: pull-dpdk pull-dpdk-devbind pull-sandbox pull-esm pull-dind

publish: build push

rmi:
	@docker rmi $(NAMESPACE)/$(DPDK_IMG):$(DPDK_VERSION) \
		$(NAMESPACE)/$(DPDK_DEVBIND_IMG):$(DPDK_VERSION) \
		$(NAMESPACE)/$(SANDBOX_IMG):$(RUST_VERSION) \
		$(NAMESPACE)/$(ESM_IMG):$(ESM_VERSION) \
		$(NAMESPACE)/$(DIND_IMG):$(DIND_VERSION)

run:
	@docker run -it --rm --privileged --network=host \
		-w /opt \
		-v /lib/modules:/lib/modules \
		-v /usr/src:/usr/src \
		-v /dev/hugepages:/dev/hugepages \
		-v $(BASE_DIR)/NetBricks:/opt/netbricks \
		-v $(BASE_DIR)/MoonGen:/opt/moongen \
		$(SANDBOX) /bin/bash
