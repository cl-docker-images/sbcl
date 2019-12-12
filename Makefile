VERSION = 1.5.9

PLATFORM := linux/amd64

ifeq ($(PLATFORM),linux/amd64)
ARCH = amd64
else ifeq ($(PLATFORM),linux/arm64)
ARCH = arm64
else ifeq ($(PLATFORM),linux/arm/v7)
ARCH = arm32v7
else
$(error Unknown ARCH)
endif

LATEST_ALPINE = 3.10
LATEST_DEBIAN = buster
LATEST_UBUNTU = disco

ALL_TARGETS =
BUILD_TARGETS =
NONBUILD_TARGETS =

ALL_TAGS =
BUILD_TAGS =
NONBUILD_TAGS =

all:

DOCKER_BUILD = docker build --pull --platform $(PLATFORM) --progress plain
DOCKER_PUSH = docker push

REPO = daewok/sbcl
VERSIONED_REPO = $(REPO):$(VERSION)




##############################################################################
# Debian Base Images
##############################################################################

debian/buster:
	$(DOCKER_BUILD) -t $(VERSIONED_REPO)-debian-buster-$(ARCH) debian/buster/$(ARCH)

debian/stretch:
	$(DOCKER_BUILD) -t $(VERSIONED_REPO)-debian-stretch-$(ARCH) debian/stretch/$(ARCH)

debian: debian/buster debian/stretch

debian-push:
	$(DOCKER_PUSH) $(VERSIONED_REPO)-debian-buster-$(ARCH)
	$(DOCKER_PUSH) $(VERSIONED_REPO)-debian-stretch-$(ARCH)

debian-manifests/buster:
	docker manifest create $(REPO):debian-buster $(VERSIONED_REPO)-debian-buster-amd64 $(VERSIONED_REPO)-debian-buster-arm64 $(VERSIONED_REPO)-debian-buster-arm32v7
	docker manifest create $(VERSIONED_REPO)-debian-buster $(VERSIONED_REPO)-debian-buster-amd64 $(VERSIONED_REPO)-debian-buster-arm64 $(VERSIONED_REPO)-debian-buster-arm32v7

debian-manifests/stretch:
	docker manifest create $(REPO):debian-stretch $(VERSIONED_REPO)-debian-stretch-amd64 $(VERSIONED_REPO)-debian-stretch-arm64 $(VERSIONED_REPO)-debian-stretch-arm32v7
	docker manifest create $(VERSIONED_REPO)-debian-stretch $(VERSIONED_REPO)-debian-stretch-amd64 $(VERSIONED_REPO)-debian-stretch-arm64 $(VERSIONED_REPO)-debian-stretch-arm32v7

debian-manifests: debian-manifests/buster debian-manifests/stretch
	docker manifest create $(REPO):debian $(VERSIONED_REPO)-debian-$(LATEST_DEBIAN)-amd64 $(VERSIONED_REPO)-debian-$(LATEST_DEBIAN)-arm64 $(VERSIONED_REPO)-debian-$(LATEST_DEBIAN)-arm32v7
	docker manifest create $(VERSIONED_REPO)-debian $(VERSIONED_REPO)-debian-$(LATEST_DEBIAN)-amd64 $(VERSIONED_REPO)-debian-$(LATEST_DEBIAN)-arm64 $(VERSIONED_REPO)-debian-$(LATEST_DEBIAN)-arm32v7

push-manifests-debian: debian-manifests
	docker manifest push $(REPO):debian-buster
	docker manifest push $(VERSIONED_REPO)-debian-buster
	docker manifest push $(REPO):debian-stretch
	docker manifest push $(VERSIONED_REPO)-debian-stretch
	docker manifest push $(REPO):debian
	docker manifest push $(VERSIONED_REPO)-debian

.PHONY: debian debian-push debian/buster debian/stretch debian-manifests debian-manifests/buster debian-manifests/stretch push-debian-manifests


##############################################################################
# Debian Build Images
##############################################################################

debian-build/buster:
	$(DOCKER_BUILD) -t $(VERSIONED_REPO)-debian-buster-build-$(ARCH) -f debian/buster/$(ARCH)/Dockerfile.build debian/buster/$(ARCH)

debian-build/stretch:
	$(DOCKER_BUILD) -t $(VERSIONED_REPO)-debian-stretch-build-$(ARCH) -f debian/stretch/$(ARCH)/Dockerfile.build debian/stretch/$(ARCH)

debian-build: debian-build/buster debian-build/stretch

debian-build-push:
	$(DOCKER_PUSH) $(VERSIONED_REPO)-debian-buster-build-$(ARCH)
	$(DOCKER_PUSH) $(VERSIONED_REPO)-debian-stretch-build-$(ARCH)

debian-build-manifests/buster:
	docker manifest create $(REPO):debian-buster-build $(VERSIONED_REPO)-debian-buster-build-amd64 $(VERSIONED_REPO)-debian-buster-build-arm64 $(VERSIONED_REPO)-debian-buster-build-arm32v7
	docker manifest create $(VERSIONED_REPO)-debian-buster-build $(VERSIONED_REPO)-debian-buster-build-amd64 $(VERSIONED_REPO)-debian-buster-build-arm64 $(VERSIONED_REPO)-debian-buster-build-arm32v7

debian-build-manifests/stretch:
	docker manifest create $(REPO):debian-stretch-build $(VERSIONED_REPO)-debian-stretch-build-amd64 $(VERSIONED_REPO)-debian-stretch-build-arm64 $(VERSIONED_REPO)-debian-stretch-build-arm32v7
	docker manifest create $(VERSIONED_REPO)-debian-stretch-build $(VERSIONED_REPO)-debian-stretch-build-amd64 $(VERSIONED_REPO)-debian-stretch-build-arm64 $(VERSIONED_REPO)-debian-stretch-build-arm32v7

debian-build-manifests: debian-build-manifests/buster debian-build-manifests/stretch
	docker manifest create $(REPO):debian-build $(VERSIONED_REPO)-debian-$(LATEST_DEBIAN)-build-amd64 $(VERSIONED_REPO)-debian-$(LATEST_DEBIAN)-build-arm64 $(VERSIONED_REPO)-debian-$(LATEST_DEBIAN)-build-arm32v7
	docker manifest create $(VERSIONED_REPO)-debian-build $(VERSIONED_REPO)-debian-$(LATEST_DEBIAN)-build-amd64 $(VERSIONED_REPO)-debian-$(LATEST_DEBIAN)-build-arm64 $(VERSIONED_REPO)-debian-$(LATEST_DEBIAN)-build-arm32v7

push-manifests-debian-build: debian-build-manifests
	docker manifest push $(REPO):debian-buster-build
	docker manifest push $(VERSIONED_REPO)-debian-buster-build
	docker manifest push $(REPO):debian-stretch-build
	docker manifest push $(VERSIONED_REPO)-debian-stretch-build
	docker manifest push $(REPO):debian-build
	docker manifest push $(VERSIONED_REPO)-debian-build

.PHONY: debian-build debian-build-push debian-build/buster debian-build/stretch debian-build-manifests debian-build-manifests/buster debian-build-manifests/stretch push-debian-build-manifests


##############################################################################
# Ubuntu Base Images
##############################################################################

ubuntu/disco:
	$(DOCKER_BUILD) -t $(VERSIONED_REPO)-ubuntu-disco-$(ARCH) ubuntu/disco/$(ARCH)

ubuntu/bionic:
	$(DOCKER_BUILD) -t $(VERSIONED_REPO)-ubuntu-bionic-$(ARCH) ubuntu/bionic/$(ARCH)

ubuntu: ubuntu/disco ubuntu/bionic

ubuntu-push:
	$(DOCKER_PUSH) $(VERSIONED_REPO)-ubuntu-disco-$(ARCH)
	$(DOCKER_PUSH) $(VERSIONED_REPO)-ubuntu-bionic-$(ARCH)

ubuntu-manifests/disco:
	docker manifest create $(REPO):ubuntu-disco $(VERSIONED_REPO)-ubuntu-disco-amd64 $(VERSIONED_REPO)-ubuntu-disco-arm64 $(VERSIONED_REPO)-ubuntu-disco-arm32v7
	docker manifest create $(VERSIONED_REPO)-ubuntu-disco $(VERSIONED_REPO)-ubuntu-disco-amd64 $(VERSIONED_REPO)-ubuntu-disco-arm64 $(VERSIONED_REPO)-ubuntu-disco-arm32v7

ubuntu-manifests/bionic:
	docker manifest create $(REPO):ubuntu-bionic $(VERSIONED_REPO)-ubuntu-bionic-amd64 $(VERSIONED_REPO)-ubuntu-bionic-arm64 $(VERSIONED_REPO)-ubuntu-bionic-arm32v7
	docker manifest create $(VERSIONED_REPO)-ubuntu-bionic $(VERSIONED_REPO)-ubuntu-bionic-amd64 $(VERSIONED_REPO)-ubuntu-bionic-arm64 $(VERSIONED_REPO)-ubuntu-bionic-arm32v7

ubuntu-manifests: ubuntu-manifests/disco ubuntu-manifests/bionic
	docker manifest create $(REPO):ubuntu $(VERSIONED_REPO)-ubuntu-$(LATEST_UBUNTU)-amd64 $(VERSIONED_REPO)-ubuntu-$(LATEST_UBUNTU)-arm64 $(VERSIONED_REPO)-ubuntu-$(LATEST_UBUNTU)-arm32v7
	docker manifest create $(VERSIONED_REPO)-ubuntu $(VERSIONED_REPO)-ubuntu-$(LATEST_UBUNTU)-amd64 $(VERSIONED_REPO)-ubuntu-$(LATEST_UBUNTU)-arm64 $(VERSIONED_REPO)-ubuntu-$(LATEST_UBUNTU)-arm32v7

push-manifests-ubuntu: ubuntu-manifests
	docker manifest push $(REPO):ubuntu-disco
	docker manifest push $(VERSIONED_REPO)-ubuntu-disco
	docker manifest push $(REPO):ubuntu-bionic
	docker manifest push $(VERSIONED_REPO)-ubuntu-bionic
	docker manifest push $(REPO):ubuntu
	docker manifest push $(VERSIONED_REPO)-ubuntu

.PHONY: ubuntu ubuntu-push ubuntu/disco ubuntu/bionic ubuntu-manifests ubuntu-manifests/disco ubuntu-manifests/bionic push-ubuntu-manifests


##############################################################################
# Ubuntu Build Images
##############################################################################

ubuntu-build/disco:
	$(DOCKER_BUILD) -t $(VERSIONED_REPO)-ubuntu-disco-build-$(ARCH) -f ubuntu/disco/$(ARCH)/Dockerfile.build ubuntu/disco/$(ARCH)

ubuntu-build/bionic:
	$(DOCKER_BUILD) -t $(VERSIONED_REPO)-ubuntu-bionic-build-$(ARCH) -f ubuntu/bionic/$(ARCH)/Dockerfile.build ubuntu/bionic/$(ARCH)

ubuntu-build: ubuntu-build/disco ubuntu-build/bionic

ubuntu-build-push:
	$(DOCKER_PUSH) $(VERSIONED_REPO)-ubuntu-disco-build-$(ARCH)
	$(DOCKER_PUSH) $(VERSIONED_REPO)-ubuntu-bionic-build-$(ARCH)

ubuntu-build-manifests/disco:
	docker manifest create $(REPO):ubuntu-disco-build $(VERSIONED_REPO)-ubuntu-disco-build-amd64 $(VERSIONED_REPO)-ubuntu-disco-build-arm64 $(VERSIONED_REPO)-ubuntu-disco-build-arm32v7
	docker manifest create $(VERSIONED_REPO)-ubuntu-disco-build $(VERSIONED_REPO)-ubuntu-disco-build-amd64 $(VERSIONED_REPO)-ubuntu-disco-build-arm64 $(VERSIONED_REPO)-ubuntu-disco-build-arm32v7

ubuntu-build-manifests/bionic:
	docker manifest create $(REPO):ubuntu-bionic-build $(VERSIONED_REPO)-ubuntu-bionic-build-amd64 $(VERSIONED_REPO)-ubuntu-bionic-build-arm64 $(VERSIONED_REPO)-ubuntu-bionic-build-arm32v7
	docker manifest create $(VERSIONED_REPO)-ubuntu-bionic-build $(VERSIONED_REPO)-ubuntu-bionic-build-amd64 $(VERSIONED_REPO)-ubuntu-bionic-build-arm64 $(VERSIONED_REPO)-ubuntu-bionic-build-arm32v7

ubuntu-build-manifests: ubuntu-build-manifests/disco ubuntu-build-manifests/bionic
	docker manifest create $(REPO):ubuntu-build $(VERSIONED_REPO)-ubuntu-$(LATEST_UBUNTU)-build-amd64 $(VERSIONED_REPO)-ubuntu-$(LATEST_UBUNTU)-build-arm64 $(VERSIONED_REPO)-ubuntu-$(LATEST_UBUNTU)-build-arm32v7
	docker manifest create $(VERSIONED_REPO)-ubuntu-build $(VERSIONED_REPO)-ubuntu-$(LATEST_UBUNTU)-build-amd64 $(VERSIONED_REPO)-ubuntu-$(LATEST_UBUNTU)-build-arm64 $(VERSIONED_REPO)-ubuntu-$(LATEST_UBUNTU)-build-arm32v7

push-manifests-ubuntu-build: ubuntu-build-manifests
	docker manifest push $(REPO):ubuntu-disco-build
	docker manifest push $(VERSIONED_REPO)-ubuntu-disco-build
	docker manifest push $(REPO):ubuntu-bionic-build
	docker manifest push $(VERSIONED_REPO)-ubuntu-bionic-build
	docker manifest push $(REPO):ubuntu-build
	docker manifest push $(VERSIONED_REPO)-ubuntu-build

.PHONY: ubuntu-build ubuntu-build-push ubuntu-build/disco ubuntu-build/bionic ubuntu-build-manifests ubuntu-build-manifests/disco ubuntu-build-manifests/bionic push-ubuntu-build-manifests


##############################################################################
# Alpine Base Images
##############################################################################

alpine/3.10:
	$(DOCKER_BUILD) -t $(VERSIONED_REPO)-alpine3.10-$(ARCH) alpine/3.10/$(ARCH)

alpine/3.9:
	$(DOCKER_BUILD) -t $(VERSIONED_REPO)-alpine3.9-$(ARCH) alpine/3.9/$(ARCH)

alpine: alpine/3.10 alpine/3.9

alpine-push:
	$(DOCKER_PUSH) $(VERSIONED_REPO)-alpine3.10-$(ARCH)
	$(DOCKER_PUSH) $(VERSIONED_REPO)-alpine3.9-$(ARCH)

alpine-manifests/3.10:
	docker manifest create $(REPO):alpine3.10 $(VERSIONED_REPO)-alpine3.10-amd64 $(VERSIONED_REPO)-alpine3.10-arm64 $(VERSIONED_REPO)-alpine3.10-arm32v7
	docker manifest create $(VERSIONED_REPO)-alpine3.10 $(VERSIONED_REPO)-alpine3.10-amd64 $(VERSIONED_REPO)-alpine3.10-arm64 $(VERSIONED_REPO)-alpine3.10-arm32v7

alpine-manifests/3.9:
	docker manifest create $(REPO):alpine3.9 $(VERSIONED_REPO)-alpine3.9-amd64 $(VERSIONED_REPO)-alpine3.9-arm64 $(VERSIONED_REPO)-alpine3.9-arm32v7
	docker manifest create $(VERSIONED_REPO)-alpine3.9 $(VERSIONED_REPO)-alpine3.9-amd64 $(VERSIONED_REPO)-alpine3.9-arm64 $(VERSIONED_REPO)-alpine3.9-arm32v7

alpine-manifests: alpine-manifests/3.10 alpine-manifests/3.9
	docker manifest create $(REPO):alpine $(VERSIONED_REPO)-alpine$(LATEST_ALPINE)-amd64 $(VERSIONED_REPO)-alpine$(LATEST_ALPINE)-arm64 $(VERSIONED_REPO)-alpine$(LATEST_ALPINE)-arm32v7
	docker manifest create $(VERSIONED_REPO)-alpine $(VERSIONED_REPO)-alpine$(LATEST_ALPINE)-amd64 $(VERSIONED_REPO)-alpine$(LATEST_ALPINE)-arm64 $(VERSIONED_REPO)-alpine$(LATEST_ALPINE)-arm32v7

push-manifests-alpine: alpine-manifests
	docker manifest push $(REPO):alpine3.10
	docker manifest push $(VERSIONED_REPO)-alpine3.10
	docker manifest push $(REPO):alpine3.9
	docker manifest push $(VERSIONED_REPO)-alpine3.9
	docker manifest push $(REPO):alpine
	docker manifest push $(VERSIONED_REPO)-alpine

.PHONY: alpine alpine-push alpine/3.10 alpine/3.9 alpine-manifests alpine-manifests/3.10 alpine-manifests/3.9 push-alpine-manifests


##############################################################################
# Alpine Build Images
##############################################################################

alpine-build/3.10:
	$(DOCKER_BUILD) -t $(VERSIONED_REPO)-alpine3.10-build-$(ARCH) -f alpine/3.10/$(ARCH)/Dockerfile.build alpine/3.10/$(ARCH)

alpine-build/3.9:
	$(DOCKER_BUILD) -t $(VERSIONED_REPO)-alpine3.9-build-$(ARCH) -f alpine/3.9/$(ARCH)/Dockerfile.build alpine/3.9/$(ARCH)

alpine-build: alpine-build/3.10 alpine-build/3.9

alpine-build-push:
	$(DOCKER_PUSH) $(VERSIONED_REPO)-alpine3.10-build-$(ARCH)
	$(DOCKER_PUSH) $(VERSIONED_REPO)-alpine3.9-build-$(ARCH)

alpine-build-manifests/3.10:
	docker manifest create $(REPO):alpine3.10-build $(VERSIONED_REPO)-alpine3.10-build-amd64 $(VERSIONED_REPO)-alpine3.10-build-arm64 $(VERSIONED_REPO)-alpine3.10-build-arm32v7
	docker manifest create $(VERSIONED_REPO)-alpine3.10-build $(VERSIONED_REPO)-alpine3.10-build-amd64 $(VERSIONED_REPO)-alpine3.10-build-arm64 $(VERSIONED_REPO)-alpine3.10-build-arm32v7

alpine-build-manifests/3.9:
	docker manifest create $(REPO):alpine3.9-build $(VERSIONED_REPO)-alpine3.9-build-amd64 $(VERSIONED_REPO)-alpine3.9-build-arm64 $(VERSIONED_REPO)-alpine3.9-build-arm32v7
	docker manifest create $(VERSIONED_REPO)-alpine3.9-build $(VERSIONED_REPO)-alpine3.9-build-amd64 $(VERSIONED_REPO)-alpine3.9-build-arm64 $(VERSIONED_REPO)-alpine3.9-build-arm32v7

alpine-build-manifests: alpine-build-manifests/3.10 alpine-build-manifests/3.9
	docker manifest create $(REPO):alpine-build $(VERSIONED_REPO)-alpine-$(LATEST_ALPINE)-build-amd64 $(VERSIONED_REPO)-alpine-$(LATEST_ALPINE)-build-arm64 $(VERSIONED_REPO)-alpine-$(LATEST_ALPINE)-build-arm32v7
	docker manifest create $(VERSIONED_REPO)-alpine-build $(VERSIONED_REPO)-alpine-$(LATEST_ALPINE)-build-amd64 $(VERSIONED_REPO)-alpine-$(LATEST_ALPINE)-build-arm64 $(VERSIONED_REPO)-alpine-$(LATEST_ALPINE)-build-arm32v7

push-manifests-alpine-build: alpine-build-manifests
	docker manifest push $(REPO):alpine3.10-build
	docker manifest push $(VERSIONED_REPO)-alpine3.10-build
	docker manifest push $(REPO):alpine3.9-build
	docker manifest push $(VERSIONED_REPO)-alpine3.9-build
	docker manifest push $(REPO):alpine-build
	docker manifest push $(VERSIONED_REPO)-alpine-build

.PHONY: alpine-build alpine-build-push alpine-build/3.10 alpine-build/3.9 alpine-build-manifests alpine-build-manifests/3.10 alpine-build-manifests/3.9 push-alpine-build-manifests

##############################################################################
# Primary entry points
##############################################################################

# all: $(ALL_TARGETS)
all-non-build: alpine debian ubuntu
all-build: alpine-build debian-build ubuntu-build

# all-build: $(BUILD_TARGETS)

# push_non_build_tags:
# 	for tag in $(NON_BUILD_TAGS); do \
# 		docker push daewok/sbcl:$$tag ; \
# 	done

# push_build_tags:
# 	for tag in $(BUILD_TAGS); do \
# 		docker push daewok/sbcl:$$tag ; \
# 	done
