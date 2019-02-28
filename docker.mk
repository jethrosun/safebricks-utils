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

GOBGP_IMG = gobgp
GOBGP_BASE_DIR = $(BASE_DIR)/gobgp
GOBGP_DOCKERFILE = $(GOBGP_BASE_DIR)/Dockerfile
GOBGP_VERSION = 2.1.0

PACKER_ANSIBLE = packer-ansible
PACKER_ANSIBLE_IMG = $(PACKER_ANSIBLE)
PACKER_ANSIBLE_BASE_DIR = $(BASE_DIR)/$(PACKER_ANSIBLE)
PACKER_ANSIBLE_DOCKERFILE = $(PACKER_ANSIBLE_BASE_DIR)/Dockerfile
ANSIBLE_VERSION = 2.7.6

.PHONY: build build-dpdk build-dpdk-devbind build-sandbox build-esm build-dind build-gobgp build-packer-ansible \
		push push-dpdk push-dpdk-devbind push-sandbox push-esm push-dind push-gobgp push-packer-ansible \
		pull pull-dpdk pull-dpdk-devbind pull-sandbox pull-esm pull-dind pull-gobgp pull-packer-ansible \
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

build-gobgp:
	@docker build -f $(GOBGP_DOCKERFILE) \
	--build-arg GOBGP=${GOBGP_VERSION} \
	-t $(NAMESPACE)/$(GOBGP_IMG):$(GOBGP_VERSION) $(GOBGP_BASE_DIR)

build-packer-ansible:
	@docker build -f $(PACKER_ANSIBLE_DOCKERFILE) \
	--build-arg ANSIBLE_VERSION=${ANSIBLE_VERSION} \
	-t $(NAMESPACE)/$(PACKER_ANSIBLE):$(ANSIBLE_VERSION) $(PACKER_ANSIBLE_BASE_DIR)

build: build-dpdk build-dpdk-devbind build-sandbox build-esm build-dind pull-gobgp build-packer-ansible

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

push-gobgp:
	@docker push $(NAMESPACE)/$(GOBGP_IMG):$(GOBGP_VERSION)

push-packer-ansible:
	@docker push $(NAMESPACE)/$(PACKER_ANSIBLE_IMG):$(ANSIBLE_VERSION)

push: push-dpdk push-dpdk-devbind push-sandbox push-esm push-dind push-gobgp push-packer-ansible

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

pull-gobgp:
	@docker pull $(NAMESPACE)/$(GOBGP_IMG):$(GOBGP_VERSION)

pull-packer-ansible:
	@docker pull $(NAMESPACE)/$(PACKER_ANSIBLE_IMG):$(ANSIBLE_VERSION)

pull: pull-dpdk pull-dpdk-devbind pull-sandbox pull-esm pull-dind pull-gobgp pull-packer-ansible

publish: build push

rmi:
	@docker rmi $(NAMESPACE)/$(DPDK_IMG):$(DPDK_VERSION) \
		$(NAMESPACE)/$(DPDK_DEVBIND_IMG):$(DPDK_VERSION) \
		$(NAMESPACE)/$(SANDBOX_IMG):$(RUST_VERSION) \
		$(NAMESPACE)/$(ESM_IMG):$(ESM_VERSION) \
		$(NAMESPACE)/$(DIND_IMG):$(DIND_VERSION) \
		$(NAMESPACE)/$(GOBGP_IMG):$(GOBGP_VERSION)

run:
	@docker run -it --rm --privileged --network=host \
		-w /opt \
		-v /lib/modules:/lib/modules \
		-v /usr/src:/usr/src \
		-v /dev/hugepages:/dev/hugepages \
		-v $(BASE_DIR)/NetBricks:/opt/netbricks \
		-v $(BASE_DIR)/MoonGen:/opt/moongen \
		$(SANDBOX) /bin/bash
