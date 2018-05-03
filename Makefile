LATEST_VERSION = 1.4.7
VERSIONS = $(notdir $(shell find versions -mindepth 1 -maxdepth 1 -type d))

LATEST_ALPINE = alpine3.7
LATEST_DEBIAN = debian-stretch
LATEST_UBUNTU = ubuntu-bionic
OSES = alpine3.7 debian-stretch ubuntu-xenial ubuntu-bionic

ALL_TARGETS =

ALL_TAGS =

all:

define DOCKER_TEMPLATE =
v$(1)-$(2):: versions/$(1)/$(2)/Dockerfile
	docker build -t daewok/sbcl:$(1)-$(2) versions/$(1)/$(2)

ALL_TARGETS += v$(1)-$(2)
ALL_TAGS += $(1)-$(2)
.PHONY: v$(1)-$(2)
endef

define LATEST_ALPINE_TEMPLATE =
v$(1)-alpine: v$(1)-$(LATEST_ALPINE)
	docker tag daewok/sbcl:$(1)-$(LATEST_ALPINE) daewok/sbcl:$(1)-alpine

ALL_TARGETS += v$(1)-alpine
ALL_TAGS += $(1)-alpine
.PHONY: v$(1)-alpine
endef

define LATEST_DEBIAN_TEMPLATE =
v$(1)-debian: v$(1)-$(LATEST_DEBIAN)
	docker tag daewok/sbcl:$(1)-$(LATEST_DEBIAN) daewok/sbcl:$(1)-debian

ALL_TARGETS += v$(1)-debian
ALL_TAGS += $(1)-debian
.PHONY: v$(1)-debian
endef

define LATEST_UBUNTU_TEMPLATE =
v$(1)-ubuntu: v$(1)-$(LATEST_UBUNTU)
	docker tag daewok/sbcl:$(1)-$(LATEST_UBUNTU) daewok/sbcl:$(1)-ubuntu

ALL_TARGETS += v$(1)-ubuntu
ALL_TAGS += $(1)-ubuntu
.PHONY: v$(1)-ubuntu
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

.PHONY: $(1)

ALL_TARGETS += $(1)
ALL_TAGS += $(1)
endef

$(foreach v,$(VERSIONS),$(call EXPAND_VERSION,$(v)))
$(foreach o,$(OSES),$(eval $(call EXPAND_OS,$(o))))

alpine-latest: v$(LATEST_VERSION)-$(LATEST_ALPINE)
	docker tag daewok/sbcl:$(LATEST_VERSION)-$(LATEST_ALPINE) daewok/sbcl:alpine

debian-latest: v$(LATEST_VERSION)-$(LATEST_DEBIAN)
	docker tag daewok/sbcl:$(LATEST_VERSION)-$(LATEST_DEBIAN) daewok/sbcl:debian

ubuntu-latest: v$(LATEST_VERSION)-$(LATEST_UBUNTU)
	docker tag daewok/sbcl:$(LATEST_VERSION)-$(LATEST_UBUNTU) daewok/sbcl:ubuntu

ALL_TAGS += alpine debian ubuntu

all: alpine-latest debian-latest ubuntu-latest $(ALL_TARGETS)

all_tags:
	@echo $(ALL_TAGS)

alpine_tags:
	@echo alpine alpine3.7

.PHONY: all all_tags
