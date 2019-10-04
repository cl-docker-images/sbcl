VERSION = 1.5.7

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

##############################################################################
# Alpine
##############################################################################

alpine: alpine/$(LATEST_ALPINE)
	docker tag daewok/sbcl:$(VERSION)-alpine$(LATEST_ALPINE) daewok/sbcl:$(VERSION)-alpine
	docker tag daewok/sbcl:$(VERSION)-alpine$(LATEST_ALPINE) daewok/sbcl:alpine

alpine-build: alpine/$(LATEST_ALPINE)-build
	docker tag daewok/sbcl:$(VERSION)-alpine$(LATEST_ALPINE)-build daewok/sbcl:$(VERSION)-alpine-build
	docker tag daewok/sbcl:$(VERSION)-alpine$(LATEST_ALPINE)-build daewok/sbcl:alpine-build

alpine/3.10:
	docker build -t daewok/sbcl:$(VERSION)-alpine3.10 alpine/3.10

alpine/3.10-build:
	docker build -t daewok/sbcl:$(VERSION)-alpine3.10-build -f alpine/3.10/Dockerfile.build alpine/3.10

alpine/3.9:
	docker build -t daewok/sbcl:$(VERSION)-alpine3.9 alpine/3.9

alpine/3.9-build:
	docker build -t daewok/sbcl:$(VERSION)-alpine3.9-build -f alpine/3.9/Dockerfile.build alpine/3.9

ALPINE_NONBUILD_TARGETS = alpine alpine/3.10 alpine/3.9
ALPINE_BUILD_TARGETS = alpine-build alpine/3.10-build alpine/3.9-build

NONBUILD_TARGETS += $(ALPINE_NONBUILD_TARGETS)
BUILD_TARGETS += $(ALPINE_BUILD_TARGETS)

ALPINE_TARGETS = $(ALPINE_NONBUILD_TARGETS) $(ALPINE_BUILD_TARGETS)
ALL_TARGETS += $(ALPINE_TARGETS)

BUILD_TAGS += $(VERSION)-alpine3.9-build $(VERSION)-alpine3.10-build $(VERSION)-alpine-build alpine-build
NONBUILD_TAGS += $(VERSION)-alpine3.9 $(VERSION)-alpine3.10 $(VERSION)-alpine alpine

.PHONY: $(ALPINE_TARGETS)

##############################################################################
# Debian
##############################################################################

debian: debian/$(LATEST_DEBIAN)
	docker tag daewok/sbcl:$(VERSION)-debian-$(LATEST_DEBIAN) daewok/sbcl:$(VERSION)-debian
	docker tag daewok/sbcl:$(VERSION)-debian-$(LATEST_DEBIAN) daewok/sbcl:debian

debian-build: debian/$(LATEST_DEBIAN)-build
	docker tag daewok/sbcl:$(VERSION)-debian-$(LATEST_DEBIAN)-build daewok/sbcl:$(VERSION)-debian-build
	docker tag daewok/sbcl:$(VERSION)-debian-$(LATEST_DEBIAN)-build daewok/sbcl:debian-build

debian/buster:
	docker build -t daewok/sbcl:$(VERSION)-debian-buster debian/buster

debian/buster-build:
	docker build -t daewok/sbcl:$(VERSION)-debian-buster-build -f debian/buster/Dockerfile.build debian/buster

debian/stretch:
	docker build -t daewok/sbcl:$(VERSION)-debian-stretch debian/stretch

debian/stretch-build:
	docker build -t daewok/sbcl:$(VERSION)-debian-stretch-build -f debian/stretch/Dockerfile.build debian/stretch

DEBIAN_NONBUILD_TARGETS = debian debian/stretch debian/buster
DEBIAN_BUILD_TARGETS = debian-build debian/stretch-build debian/buster-build

NONBUILD_TARGETS += $(DEBIAN_NONBUILD_TARGETS)
BUILD_TARGETS += $(DEBIAN_BUILD_TARGETS)

DEBIAN_TARGETS = $(DEBIAN_NONBUILD_TARGETS) $(DEBIAN_BUILD_TARGETS)
ALL_TARGETS += $(DEBIAN_TARGETS)

BUILD_TAGS += $(VERSION)-debian-buster-build $(VERSION)-debian-stretch-build $(VERSION)-debian-build debian-build
NONBUILD_TAGS += $(VERSION)-debian-buster $(VERSION)-debian-stretch $(VERSION)-debian debian

.PHONY: $(DEBIAN_TARGETS)

##############################################################################
# Ubuntu
##############################################################################

ubuntu: ubuntu/$(LATEST_UBUNTU)
	docker tag daewok/sbcl:$(VERSION)-ubuntu-$(LATEST_UBUNTU) daewok/sbcl:$(VERSION)-ubuntu
	docker tag daewok/sbcl:$(VERSION)-ubuntu-$(LATEST_UBUNTU) daewok/sbcl:ubuntu

ubuntu-build: ubuntu/$(LATEST_UBUNTU)-build
	docker tag daewok/sbcl:$(VERSION)-ubuntu-$(LATEST_UBUNTU)-build daewok/sbcl:$(VERSION)-ubuntu-build
	docker tag daewok/sbcl:$(VERSION)-ubuntu-$(LATEST_UBUNTU)-build daewok/sbcl:ubuntu-build

ubuntu/bionic:
	docker build -t daewok/sbcl:$(VERSION)-ubuntu-bionic ubuntu/bionic

ubuntu/bionic-build:
	docker build -t daewok/sbcl:$(VERSION)-ubuntu-bionic-build -f ubuntu/bionic/Dockerfile.build ubuntu/bionic

ubuntu/disco:
	docker build -t daewok/sbcl:$(VERSION)-ubuntu-disco ubuntu/disco

ubuntu/disco-build:
	docker build -t daewok/sbcl:$(VERSION)-ubuntu-disco-build -f ubuntu/disco/Dockerfile.build ubuntu/disco

UBUNTU_NONBUILD_TARGETS = ubuntu ubuntu/bionic ubuntu/disco
UBUNTU_BUILD_TARGETS = ubuntu-build ubuntu/bionic-build ubuntu/disco-build

NONBUILD_TARGETS += $(UBUNTU_NONBUILD_TARGETS)
BUILD_TARGETS += $(UBUNTU_BUILD_TARGETS)

UBUNTU_TARGETS = $(UBUNTU_NONBUILD_TARGETS) $(UBUNTU_BUILD_TARGETS)
ALL_TARGETS += $(UBUNTU_TARGETS)

BUILD_TAGS += $(VERSION)-ubuntu-bionic-build $(VERSION)-ubuntu-disco-build $(VERSION)-ubuntu-build ubuntu-build
NONBUILD_TAGS += $(VERSION)-ubuntu-bionic $(VERSION)-ubuntu-disco $(VERSION)-ubuntu ubuntu

.PHONY: $(UBUNTU_TARGETS)

##############################################################################
# Primary entry points
##############################################################################

all: $(ALL_TARGETS)
all-non-build: $(NONBUILD_TARGETS)
all-build: $(BUILD_TARGETS)

push_non_build_tags:
	for tag in $(NON_BUILD_TAGS); do \
		docker push daewok/sbcl:$$tag ; \
	done

push_build_tags:
	for tag in $(BUILD_TAGS); do \
		docker push daewok/sbcl:$$tag ; \
	done
