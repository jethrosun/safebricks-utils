#############
# VARIABLES #
#############

# Add to recipes to silence output
SILENT ?= &> /dev/null

# Variables for downloading coreos images. Because stable `corectl`
# has not been updated with the latest signing key, and the unstable
# version doesn't work, we have to download boot images ourselves.
VMLINUZ := coreos_production_pxe.vmlinuz
IMAGE := coreos_production_pxe_image.cpio.gz
COREOS_CHANNEL ?= alpha

# Including the downloaded version file for its variables
-include corectl/$(COREOS_CHANNEL)-version.txt

COREOS_IMAGE_REPO = https://$(COREOS_CHANNEL).release.core-os.net/amd64-usr
COREOS_IMAGE_PATH = $(HOME)/.coreos/images/$(COREOS_CHANNEL)/$(COREOS_VERSION)

# Command-line tools we need to run our targets. These will be
# installed if they don't exist.
QCOW     ?= $(or $(shell which qcow-tool),/usr/local/bin/qcow-tool)
CORECTL  ?= $(or $(shell which corectl),/usr/local/bin/corectl)
CORECTLD ?= $(or $(shell which corectld),/usr/local/bin/corectld)

# Size of the attached sparse qcow2 disk
CORECTL_VOLUME_SIZE ?= 40GiB

# Parameters for the final VM that we create
CORECTL_VM_NAME ?= occam-dev
CORECTL_CPUS    ?= 2
CORECTL_RAM     ?= 4096
CORECTL_VOLUME  ?= occam-dev-docker.img.qcow2
CORECTL_INIT    ?= corectl/cloud-init.yaml
CORECTL_KERNEL_FLAGS ?= "hugepages=1024"

# Flags for the `corectl run` command that will start the vm.
CORECTL_RUN_FLAGS = -b $(CORECTL_KERNEL_FLAGS) \
                    -n $(CORECTL_VM_NAME) \
                    -N $(CORECTL_CPUS) \
                    -m $(CORECTL_RAM) \
                    -p $(CORECTL_VOLUME) \
                    -L $(CORECTL_INIT) \
                    -v $(COREOS_VERSION) \
                    -c $(COREOS_CHANNEL) \
                    -H \
                    -o

# The CoreOS image files needed to boot a VM
IMAGES = corectl/$(COREOS_CHANNEL)-version.txt $(COREOS_IMAGE_PATH)/$(VMLINUZ) $(COREOS_IMAGE_PATH)/$(IMAGE)

# Starts `corectld` idempotently
START_DAEMON = $(CORECTLD) status ${SILENT} || \
                (echo "--- Starting corectl daemon, enter your password when prompted..." && \
                $(CORECTLD) start ${SILENT})

###################
# RECIPES/TARGETS #
###################

# Targets that aren't files
.PHONY: daemon destroy images sync vm volume

# Ensure that files are cleaned up (e.g. the persistent disk or VM
# images) when a target fails
.DELETE_ON_ERROR:

# Starts the VM
vm: $(CORECTL_VOLUME) $(CORECTL_INIT)
	@$(START_DAEMON)
	@($(CORECTL) q $(CORECTL_VM_NAME) ${SILENT} && echo '--- VM already running!') ||\
	    (echo "--- Booting $(CORECTL_VM_NAME) VM" && $(CORECTL) run $(CORECTL_RUN_FLAGS))

# Checks the persistent volume for errors
volume: $(CORECTL_VOLUME) $(QCOW)
	@$(QCOW) check $(CORECTL_VOLUME)

# Creates the persistent disk for the VM
$(CORECTL_VOLUME): $(IMAGES) $(QCOW) $(CORECTL)
	@$(START_DAEMON)
	@echo "--- Creating qcow2 $(CORECTL_VOLUME) image in $@..."
	@$(QCOW) create --size=$(CORECTL_VOLUME_SIZE) $(CORECTL_VOLUME)
	@echo "--- Formatting image as ext4..."
	@$(CORECTL) run -n occam-fmt -p $(CORECTL_VOLUME) -N 2 -m 2048 -o
	@$(CORECTL) ssh occam-fmt "sudo mke2fs -b 1024 -i 1024 -t ext4 -m0 /dev/vda && \
            sudo e2label /dev/vda rkthdd"
	@$(CORECTL) halt occam-fmt

# Idempotently starts `corectld`
daemon: $(CORECTLD)
	@$(START_DAEMON)

# Downloads the version information for the current CoreOS release
corectl/$(COREOS_CHANNEL)-version.txt:
	@echo "--- Fetching version information for $(COREOS_CHANNEL) channel"
	@curl -# -o $@ $(COREOS_IMAGE_REPO)/current/version.txt

# Downloads the CoreOS VM images
$(COREOS_IMAGE_PATH)/$(VMLINUZ) $(COREOS_IMAGE_PATH)/$(IMAGE): $(COREOS_IMAGE_PATH)
	@echo "--- Fetching CoreOS image $(@F)"
	@curl -# -o $@ $(COREOS_IMAGE_REPO)/$(COREOS_VERSION)/$(@F)

$(COREOS_IMAGE_PATH):
	@mkdir -p $@

# Installs corectl with homebrew
$(CORECTL) $(CORECTLD) $(QCOW):
	@brew install corectl

# Halts the vm and removes the persistent volume
destroy: $(CORECTL)
	-@$(CORECTL) halt $(CORECTL_VM_NAME) ${SILENT}
	-@rm -f $(CORECTL_VOLUME) ${SILENT}

# Prints environment variables needed for Docker setup
env:
	@$(CORECTL) q $(CORECTL_VM_NAME) ${SILENT} && \
	    echo "export DOCKER_HOST=tcp://$(shell $(CORECTL) q -i $(CORECTL_VM_NAME)):2375"
