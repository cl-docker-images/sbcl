VERSION = 1.5.7

ARCHES := linux/amd64,linux/arm/v7

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

DOCKER_BUILD = docker build --pull --platform $$ARCH --load

REPO = daewok/sbcl
VERSIONED_REPO = $(REPO):$(VERSION)




##############################################################################
# Debian Base Images
##############################################################################

debian: debian/buster debian/stretch
	docker manifest create --amend $(REPO):debian $(VERSIONED_REPO)-debian-buster-amd64 $(VERSIONED_REPO)-debian-buster-arm32v7
	docker manifest create --amend $(VERSIONED_REPO)-debian $(VERSIONED_REPO)-debian-buster-amd64 $(VERSIONED_REPO)-debian-buster-arm32v7

	docker manifest push $(REPO):debian
	docker manifest push $(VERSIONED_REPO)-debian

debian/buster: debian/buster-amd64 debian/buster-arm32v7
	docker manifest create --amend $(VERSIONED_REPO)-debian-buster $(VERSIONED_REPO)-debian-buster-amd64 $(VERSIONED_REPO)-debian-buster-arm32v7
	docker manifest push $(VERSIONED_REPO)-debian-buster

debian/buster-amd64: export ARCH = linux/amd64
debian/buster-amd64:
	$(DOCKER_BUILD) -t $(VERSIONED_REPO)-debian-buster-amd64 debian/buster
	docker push $(VERSIONED_REPO)-debian-buster-amd64

debian/buster-arm32v7: export ARCH = linux/arm/v7
debian/buster-arm32v7:
	$(DOCKER_BUILD) -t $(VERSIONED_REPO)-debian-buster-arm32v7 debian/buster
	docker push $(VERSIONED_REPO)-debian-buster-arm32v7


debian/stretch: debian/stretch-amd64 debian/stretch-arm32v7
	docker manifest create --amend $(VERSIONED_REPO)-debian-stretch $(VERSIONED_REPO)-debian-stretch-amd64 $(VERSIONED_REPO)-debian-stretch-arm32v7
	docker manifest push $(VERSIONED_REPO)-debian-stretch

debian/stretch-amd64: export ARCH = linux/amd64
debian/stretch-amd64:
	$(DOCKER_BUILD) -t $(VERSIONED_REPO)-debian-stretch-amd64 debian/stretch
	docker push $(VERSIONED_REPO)-debian-stretch-amd64

debian/stretch-arm32v7: export ARCH = linux/arm/v7
debian/stretch-arm32v7:
	$(DOCKER_BUILD) -t $(VERSIONED_REPO)-debian-stretch-arm32v7 debian/stretch
	docker push $(VERSIONED_REPO)-debian-stretch-arm32v7

##############################################################################
# Debian Build Images
##############################################################################

debian-build: debian/buster-build debian/stretch-build
	docker manifest create --amend $(REPO):debian-build $(VERSIONED_REPO)-debian-buster-build-amd64 $(VERSIONED_REPO)-debian-buster-build-arm32v7
	docker manifest create --amend $(VERSIONED_REPO)-debian-build $(VERSIONED_REPO)-debian-buster-build-amd64 $(VERSIONED_REPO)-debian-buster-build-arm32v7

	docker manifest push $(REPO):debian-build
	docker manifest push $(VERSIONED_REPO)-debian-build

debian/buster-build: debian/buster-build-amd64 debian/buster-build-arm32v7
	docker manifest create --amend $(VERSIONED_REPO)-debian-buster-build $(VERSIONED_REPO)-debian-buster-build-amd64 $(VERSIONED_REPO)-debian-buster-build-arm32v7
	docker manifest push $(VERSIONED_REPO)-debian-buster-build

debian/buster-build-amd64: export ARCH = linux/amd64
debian/buster-build-amd64: debian/buster
	$(DOCKER_BUILD) -t $(VERSIONED_REPO)-debian-buster-build-amd64 -f debian/buster/Dockerfile.build debian/buster
	docker push $(VERSIONED_REPO)-debian-buster-build-amd64

debian/buster-build-arm32v7: export ARCH = linux/arm/v7
debian/buster-build-arm32v7: debian/buster
	$(DOCKER_BUILD) -t $(VERSIONED_REPO)-debian-buster-build-arm32v7 -f debian/buster/Dockerfile.build debian/buster
	docker push $(VERSIONED_REPO)-debian-buster-build-arm32v7



debian/stretch-build: debian/stretch-build-amd64 debian/stretch-build-arm32v7
	docker manifest create --amend $(VERSIONED_REPO)-debian-stretch-build $(VERSIONED_REPO)-debian-stretch-build-amd64 $(VERSIONED_REPO)-debian-stretch-build-arm32v7
	docker manifest push $(VERSIONED_REPO)-debian-stretch-build

debian/stretch-build-amd64: export ARCH = linux/amd64
debian/stretch-build-amd64: debian/stretch
	$(DOCKER_BUILD) -t $(VERSIONED_REPO)-debian-stretch-build-amd64 -f debian/stretch/Dockerfile.build debian/stretch
	docker push $(VERSIONED_REPO)-debian-stretch-build-amd64

debian/stretch-build-arm32v7: export ARCH = linux/arm/v7
debian/stretch-build-arm32v7: debian/stretch
	$(DOCKER_BUILD) -t $(VERSIONED_REPO)-debian-stretch-build-arm32v7 -f debian/stretch/Dockerfile.build debian/stretch
	docker push $(VERSIONED_REPO)-debian-stretch-build-arm32v7


##############################################################################
# Ubuntu Base Images
##############################################################################

ubuntu: ubuntu/disco ubuntu/bionic
	docker manifest create --amend $(REPO):ubuntu $(VERSIONED_REPO)-ubuntu-disco-amd64 $(VERSIONED_REPO)-ubuntu-disco-arm32v7
	docker manifest create --amend $(VERSIONED_REPO)-ubuntu $(VERSIONED_REPO)-ubuntu-disco-amd64 $(VERSIONED_REPO)-ubuntu-disco-arm32v7

	docker manifest push $(REPO):ubuntu
	docker manifest push $(VERSIONED_REPO)-ubuntu

ubuntu/disco: ubuntu/disco-amd64 ubuntu/disco-arm32v7
	docker manifest create --amend $(VERSIONED_REPO)-ubuntu-disco $(VERSIONED_REPO)-ubuntu-disco-amd64 $(VERSIONED_REPO)-ubuntu-disco-arm32v7
	docker manifest push $(VERSIONED_REPO)-ubuntu-disco

ubuntu/disco-amd64: export ARCH = linux/amd64
ubuntu/disco-amd64:
	$(DOCKER_BUILD) -t $(VERSIONED_REPO)-ubuntu-disco-amd64 ubuntu/disco
	docker push $(VERSIONED_REPO)-ubuntu-disco-amd64

ubuntu/disco-arm32v7: export ARCH = linux/arm/v7
ubuntu/disco-arm32v7:
	$(DOCKER_BUILD) -t $(VERSIONED_REPO)-ubuntu-disco-arm32v7 ubuntu/disco
	docker push $(VERSIONED_REPO)-ubuntu-disco-arm32v7


ubuntu/bionic: ubuntu/bionic-amd64 ubuntu/bionic-arm32v7
	docker manifest create --amend $(VERSIONED_REPO)-ubuntu-bionic $(VERSIONED_REPO)-ubuntu-bionic-amd64 $(VERSIONED_REPO)-ubuntu-bionic-arm32v7
	docker manifest push $(VERSIONED_REPO)-ubuntu-bionic

ubuntu/bionic-amd64: export ARCH = linux/amd64
ubuntu/bionic-amd64:
	$(DOCKER_BUILD) -t $(VERSIONED_REPO)-ubuntu-bionic-amd64 ubuntu/bionic
	docker push $(VERSIONED_REPO)-ubuntu-bionic-amd64

ubuntu/bionic-arm32v7: export ARCH = linux/arm/v7
ubuntu/bionic-arm32v7:
	$(DOCKER_BUILD) -t $(VERSIONED_REPO)-ubuntu-bionic-arm32v7 ubuntu/bionic
	docker push $(VERSIONED_REPO)-ubuntu-bionic-arm32v7

##############################################################################
# Ubuntu Build Images
##############################################################################

ubuntu-build: ubuntu/disco-build ubuntu/bionic-build
	docker manifest create --amend $(REPO):ubuntu-build $(VERSIONED_REPO)-ubuntu-disco-build-amd64 $(VERSIONED_REPO)-ubuntu-disco-build-arm32v7
	docker manifest create --amend $(VERSIONED_REPO)-ubuntu-build $(VERSIONED_REPO)-ubuntu-disco-build-amd64 $(VERSIONED_REPO)-ubuntu-disco-build-arm32v7

	docker manifest push $(REPO):ubuntu-build
	docker manifest push $(VERSIONED_REPO)-ubuntu-build

ubuntu/disco-build: ubuntu/disco-build-amd64 ubuntu/disco-build-arm32v7
	docker manifest create --amend $(VERSIONED_REPO)-ubuntu-disco-build $(VERSIONED_REPO)-ubuntu-disco-build-amd64 $(VERSIONED_REPO)-ubuntu-disco-build-arm32v7
	docker manifest push $(VERSIONED_REPO)-ubuntu-disco-build

ubuntu/disco-build-amd64: export ARCH = linux/amd64
ubuntu/disco-build-amd64: ubuntu/disco
	$(DOCKER_BUILD) -t $(VERSIONED_REPO)-ubuntu-disco-build-amd64 -f ubuntu/disco/Dockerfile.build ubuntu/disco
	docker push $(VERSIONED_REPO)-ubuntu-disco-build-amd64

ubuntu/disco-build-arm32v7: export ARCH = linux/arm/v7
ubuntu/disco-build-arm32v7: ubuntu/disco
	$(DOCKER_BUILD) -t $(VERSIONED_REPO)-ubuntu-disco-build-arm32v7 -f ubuntu/disco/Dockerfile.build ubuntu/disco
	docker push $(VERSIONED_REPO)-ubuntu-disco-build-arm32v7



ubuntu/bionic-build: ubuntu/bionic-build-amd64 ubuntu/bionic-build-arm32v7
	docker manifest create --amend $(VERSIONED_REPO)-ubuntu-bionic-build $(VERSIONED_REPO)-ubuntu-bionic-build-amd64 $(VERSIONED_REPO)-ubuntu-bionic-build-arm32v7
	docker manifest push $(VERSIONED_REPO)-ubuntu-bionic-build

ubuntu/bionic-build-amd64: export ARCH = linux/amd64
ubuntu/bionic-build-amd64: ubuntu/bionic
	$(DOCKER_BUILD) -t $(VERSIONED_REPO)-ubuntu-bionic-build-amd64 -f ubuntu/bionic/Dockerfile.build ubuntu/bionic
	docker push $(VERSIONED_REPO)-ubuntu-bionic-build-amd64

ubuntu/bionic-build-arm32v7: export ARCH = linux/arm/v7
ubuntu/bionic-build-arm32v7: ubuntu/bionic
	$(DOCKER_BUILD) -t $(VERSIONED_REPO)-ubuntu-bionic-build-arm32v7 -f ubuntu/bionic/Dockerfile.build ubuntu/bionic
	docker push $(VERSIONED_REPO)-ubuntu-bionic-build-arm32v7


# ##############################################################################
# # Alpine
# ##############################################################################

# alpine: alpine/$(LATEST_ALPINE)
# 	docker tag daewok/sbcl:$(VERSION)-alpine$(LATEST_ALPINE) daewok/sbcl:$(VERSION)-alpine
# 	docker tag daewok/sbcl:$(VERSION)-alpine$(LATEST_ALPINE) daewok/sbcl:alpine

# alpine-build: alpine/$(LATEST_ALPINE)-build
# 	docker tag daewok/sbcl:$(VERSION)-alpine$(LATEST_ALPINE)-build daewok/sbcl:$(VERSION)-alpine-build
# 	docker tag daewok/sbcl:$(VERSION)-alpine$(LATEST_ALPINE)-build daewok/sbcl:alpine-build

# alpine/3.10:
# 	$(DOCKER_BUILD) -t daewok/sbcl:$(VERSION)-alpine3.10-amd64 alpine/3.10

# alpine/3.10-build:
# 	$(DOCKER_BUILD) -t daewok/sbcl:$(VERSION)-alpine3.10-build -f alpine/3.10/Dockerfile.build alpine/3.10

# alpine/3.9:
# 	$(DOCKER_BUILD) -t daewok/sbcl:$(VERSION)-alpine3.9-amd64 alpine/3.9

# alpine/3.9-build:
# 	$(DOCKER_BUILD) -t daewok/sbcl:$(VERSION)-alpine3.9-build -f alpine/3.9/Dockerfile.build alpine/3.9

# ALPINE_NONBUILD_TARGETS = alpine alpine/3.10 alpine/3.9
# ALPINE_BUILD_TARGETS = alpine-build alpine/3.10-build alpine/3.9-build

# NONBUILD_TARGETS += $(ALPINE_NONBUILD_TARGETS)
# BUILD_TARGETS += $(ALPINE_BUILD_TARGETS)

# ALPINE_TARGETS = $(ALPINE_NONBUILD_TARGETS) $(ALPINE_BUILD_TARGETS)
# ALL_TARGETS += $(ALPINE_TARGETS)

# BUILD_TAGS += $(VERSION)-alpine3.9-build $(VERSION)-alpine3.10-build $(VERSION)-alpine-build alpine-build
# NONBUILD_TAGS += $(VERSION)-alpine3.9 $(VERSION)-alpine3.10 $(VERSION)-alpine alpine

# .PHONY: $(ALPINE_TARGETS)

# ##############################################################################
# # Debian
# ##############################################################################

# debian: debian/$(LATEST_DEBIAN)
# 	docker tag daewok/sbcl:$(VERSION)-debian-$(LATEST_DEBIAN) daewok/sbcl:$(VERSION)-debian
# 	docker tag daewok/sbcl:$(VERSION)-debian-$(LATEST_DEBIAN) daewok/sbcl:debian

# debian-build: debian/$(LATEST_DEBIAN)-build
# 	docker tag daewok/sbcl:$(VERSION)-debian-$(LATEST_DEBIAN)-build daewok/sbcl:$(VERSION)-debian-build
# 	docker tag daewok/sbcl:$(VERSION)-debian-$(LATEST_DEBIAN)-build daewok/sbcl:debian-build

# debian/buster:
# 	$(DOCKER_BUILD) -t daewok/sbcl:$(VERSION)-debian-buster-amd64 debian/buster
# 	$(ARM_DOCKER_BUILD) -t daewok/sbcl:$(VERSION)-debian-buster-arm32v7 debian/buster

# debian/buster-build:
# 	$(DOCKER_BUILD) -t daewok/sbcl:$(VERSION)-debian-buster-build -f debian/buster/Dockerfile.build debian/buster

# debian/stretch:
# 	$(DOCKER_BUILD) -t daewok/sbcl:$(VERSION)-debian-stretch-amd64 debian/stretch
# 	$(ARM_DOCKER_BUILD) -t daewok/sbcl:$(VERSION)-debian-stretch-arm32v7 debian/stretch

# debian/stretch-build:
# 	$(DOCKER_BUILD) -t daewok/sbcl:$(VERSION)-debian-stretch-build -f debian/stretch/Dockerfile.build debian/stretch

# DEBIAN_NONBUILD_TARGETS = debian debian/stretch debian/buster
# DEBIAN_BUILD_TARGETS = debian-build debian/stretch-build debian/buster-build

# NONBUILD_TARGETS += $(DEBIAN_NONBUILD_TARGETS)
# BUILD_TARGETS += $(DEBIAN_BUILD_TARGETS)

# DEBIAN_TARGETS = $(DEBIAN_NONBUILD_TARGETS) $(DEBIAN_BUILD_TARGETS)
# ALL_TARGETS += $(DEBIAN_TARGETS)

# BUILD_TAGS += $(VERSION)-debian-buster-build $(VERSION)-debian-stretch-build $(VERSION)-debian-build debian-build
# NONBUILD_TAGS += $(VERSION)-debian-buster $(VERSION)-debian-stretch $(VERSION)-debian debian

# .PHONY: $(DEBIAN_TARGETS)

# ##############################################################################
# # Ubuntu
# ##############################################################################

# ubuntu: ubuntu/$(LATEST_UBUNTU)
# 	docker tag daewok/sbcl:$(VERSION)-ubuntu-$(LATEST_UBUNTU) daewok/sbcl:$(VERSION)-ubuntu
# 	docker tag daewok/sbcl:$(VERSION)-ubuntu-$(LATEST_UBUNTU) daewok/sbcl:ubuntu

# ubuntu-build: ubuntu/$(LATEST_UBUNTU)-build
# 	docker tag daewok/sbcl:$(VERSION)-ubuntu-$(LATEST_UBUNTU)-build daewok/sbcl:$(VERSION)-ubuntu-build
# 	docker tag daewok/sbcl:$(VERSION)-ubuntu-$(LATEST_UBUNTU)-build daewok/sbcl:ubuntu-build

# ubuntu/bionic:
# 	$(DOCKER_BUILD) -t daewok/sbcl:$(VERSION)-ubuntu-bionic-amd64 ubuntu/bionic
# 	$(ARM_DOCKER_BUILD) -t daewok/sbcl:$(VERSION)-ubuntu-bionic-arm32v7 ubuntu/bionic

# ubuntu/bionic-build:
# 	$(DOCKER_BUILD) -t daewok/sbcl:$(VERSION)-ubuntu-bionic-build -f ubuntu/bionic/Dockerfile.build ubuntu/bionic

# ubuntu/disco:
# 	$(DOCKER_BUILD) -t daewok/sbcl:$(VERSION)-ubuntu-disco-amd64 ubuntu/disco
# 	$(ARM_DOCKER_BUILD) -t daewok/sbcl:$(VERSION)-ubuntu-disco-arm32v7 ubuntu/disco

# ubuntu/disco-build:
# 	$(DOCKER_BUILD) -t daewok/sbcl:$(VERSION)-ubuntu-disco-build -f ubuntu/disco/Dockerfile.build ubuntu/disco

# UBUNTU_NONBUILD_TARGETS = ubuntu ubuntu/bionic ubuntu/disco
# UBUNTU_BUILD_TARGETS = ubuntu-build ubuntu/bionic-build ubuntu/disco-build

# NONBUILD_TARGETS += $(UBUNTU_NONBUILD_TARGETS)
# BUILD_TARGETS += $(UBUNTU_BUILD_TARGETS)

# UBUNTU_TARGETS = $(UBUNTU_NONBUILD_TARGETS) $(UBUNTU_BUILD_TARGETS)
# ALL_TARGETS += $(UBUNTU_TARGETS)

# BUILD_TAGS += $(VERSION)-ubuntu-bionic-build $(VERSION)-ubuntu-disco-build $(VERSION)-ubuntu-build ubuntu-build
# NONBUILD_TAGS += $(VERSION)-ubuntu-bionic $(VERSION)-ubuntu-disco $(VERSION)-ubuntu ubuntu

# .PHONY: $(UBUNTU_TARGETS)

# ##############################################################################
# # Primary entry points
# ##############################################################################

# all: $(ALL_TARGETS)
# all-non-build: $(NONBUILD_TARGETS)
# all-build: $(BUILD_TARGETS)

# push_non_build_tags:
# 	for tag in $(NON_BUILD_TAGS); do \
# 		docker push daewok/sbcl:$$tag ; \
# 	done

# push_build_tags:
# 	for tag in $(BUILD_TAGS); do \
# 		docker push daewok/sbcl:$$tag ; \
# 	done
