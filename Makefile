LATEST_VERSION = 1.5.0
VERSIONS = $(notdir $(shell find versions -mindepth 1 -maxdepth 1 -type d))

LATEST_ALPINE = alpine3.8
LATEST_DEBIAN = debian-stretch
LATEST_UBUNTU = ubuntu-cosmic
OSES = alpine3.8 debian-stretch ubuntu-bionic ubuntu-cosmic

ALL_TARGETS =

ALL_TAGS =

all:

define DOCKER_TEMPLATE =
v$(1)-$(2):: versions/$(1)/$(2)/Dockerfile
	docker build -t daewok/sbcl:$(1)-$(2) versions/$(1)/$(2)

v$(1)-$(2)-build:: v$(1)-$(2) versions/$(1)/$(2)/Dockerfile.build
	docker build -t daewok/sbcl:$(1)-$(2)-build -f versions/$(1)/$(2)/Dockerfile.build versions/$(1)/$(2)

ALL_TARGETS += v$(1)-$(2) v$(1)-$(2)-build
ALL_TAGS += $(1)-$(2) $(1)-$(2)-build
.PHONY: v$(1)-$(2) v$(1)-$(2)-build
endef

define LATEST_ALPINE_TEMPLATE =
v$(1)-alpine: v$(1)-$(LATEST_ALPINE)
	docker tag daewok/sbcl:$(1)-$(LATEST_ALPINE) daewok/sbcl:$(1)-alpine

v$(1)-alpine-build: v$(1)-$(LATEST_ALPINE)-build
	docker tag daewok/sbcl:$(1)-$(LATEST_ALPINE)-build daewok/sbcl:$(1)-alpine-build

ALL_TARGETS += v$(1)-alpine v$(1)-alpine-build
ALL_TAGS += $(1)-alpine $(1)-alpine-build
.PHONY: v$(1)-alpine v$(1)-alpine-build
endef

define LATEST_DEBIAN_TEMPLATE =
v$(1)-debian: v$(1)-$(LATEST_DEBIAN)
	docker tag daewok/sbcl:$(1)-$(LATEST_DEBIAN) daewok/sbcl:$(1)-debian

v$(1)-debian-build: v$(1)-$(LATEST_DEBIAN)-build
	docker tag daewok/sbcl:$(1)-$(LATEST_DEBIAN)-build daewok/sbcl:$(1)-debian-build

ALL_TARGETS += v$(1)-debian v$(1)-debian-build
ALL_TAGS += $(1)-debian $(1)-debian-build
.PHONY: v$(1)-debian v$(1)-debian-build
endef

define LATEST_UBUNTU_TEMPLATE =
v$(1)-ubuntu: v$(1)-$(LATEST_UBUNTU)
	docker tag daewok/sbcl:$(1)-$(LATEST_UBUNTU) daewok/sbcl:$(1)-ubuntu

v$(1)-ubuntu-build: v$(1)-$(LATEST_UBUNTU)-build
	docker tag daewok/sbcl:$(1)-$(LATEST_UBUNTU)-build daewok/sbcl:$(1)-ubuntu-build

ALL_TARGETS += v$(1)-ubuntu v$(1)-ubuntu-build
ALL_TAGS += $(1)-ubuntu $(1)-ubuntu-build
.PHONY: v$(1)-ubuntu v$(1)-ubuntu-build
endef

define EXPAND_VERSION =
$(foreach os,$(OSES),$(eval $(call DOCKER_TEMPLATE,$(1),$(os))))

$(eval $(call LATEST_ALPINE_TEMPLATE,$(1)))
$(eval $(call LATEST_DEBIAN_TEMPLATE,$(1)))
$(eval $(call LATEST_UBUNTU_TEMPLATE,$(1)))

endef


define EXPAND_OS =
$(1): v$(LATEST_VERSION)-$(1)
	docker tag daewok/sbcl:$(LATEST_VERSION)-$(1) daewok/sbcl:$(1)

$(1)-build: v$(LATEST_VERSION)-$(1)-build
	docker tag daewok/sbcl:$(LATEST_VERSION)-$(1)-build daewok/sbcl:$(1)-build

.PHONY: $(1)

ALL_TARGETS += $(1) $(1)-build
ALL_TAGS += $(1) $(1)-build
endef

$(foreach v,$(VERSIONS),$(call EXPAND_VERSION,$(v)))
$(foreach o,$(OSES),$(eval $(call EXPAND_OS,$(o))))

alpine-latest: v$(LATEST_VERSION)-$(LATEST_ALPINE)
	docker tag daewok/sbcl:$(LATEST_VERSION)-$(LATEST_ALPINE) daewok/sbcl:alpine

alpine-latest-build: v$(LATEST_VERSION)-$(LATEST_ALPINE)-build
	docker tag daewok/sbcl:$(LATEST_VERSION)-$(LATEST_ALPINE)-build daewok/sbcl:alpine-build

debian-latest: v$(LATEST_VERSION)-$(LATEST_DEBIAN)
	docker tag daewok/sbcl:$(LATEST_VERSION)-$(LATEST_DEBIAN) daewok/sbcl:debian

debian-latest-build: v$(LATEST_VERSION)-$(LATEST_DEBIAN)-build
	docker tag daewok/sbcl:$(LATEST_VERSION)-$(LATEST_DEBIAN)-build daewok/sbcl:debian-build

ubuntu-latest: v$(LATEST_VERSION)-$(LATEST_UBUNTU)
	docker tag daewok/sbcl:$(LATEST_VERSION)-$(LATEST_UBUNTU) daewok/sbcl:ubuntu

ubuntu-latest-build: v$(LATEST_VERSION)-$(LATEST_UBUNTU)-build
	docker tag daewok/sbcl:$(LATEST_VERSION)-$(LATEST_UBUNTU)-build daewok/sbcl:ubuntu-build

ALL_TAGS += alpine alpine-build debian debian-build ubuntu ubuntu-build

all: alpine-latest alpine-latest-build debian-latest debian-latest-build ubuntu-latest ubuntu-latest-build $(ALL_TARGETS)

all_tags:
	@echo $(ALL_TAGS)

alpine_tags:
	@echo alpine alpine3.8

.PHONY: all all_tags
