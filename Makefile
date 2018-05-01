SBCL_VERSION := 1.4.7

all: alpine

alpine-3.7:
	docker build -t daewok/sbcl:$(SBCL_VERSION)-alpine-3.7 \
		--build-arg SBCL_VERSION=$(SBCL_VERSION) \
		versions/alpine-3.7

alpine: alpine-3.7

latest-alpine: alpine-3.7
	docker tag daewok/sbcl:$(SBCL_VERSION)-alpine-3.7 daewok/sbcl:alpine
	docker tag daewok/sbcl:$(SBCL_VERSION)-alpine-3.7 daewok/sbcl:alpine-3.7

debian-stretch:
	docker build -t daewok/sbcl:$(SBCL_VERSION)-debian-stretch \
		--build-arg SBCL_VERSION=$(SBCL_VERSION) \
		versions/debian-stretch

debian: debian-stretch

latest-debian: debian-stretch
	docker tag daewok/sbcl:$(SBCL_VERSION)-debian-stretch daewok/sbcl:debian
	docker tag daewok/sbcl:$(SBCL_VERSION)-debian-stretch daewok/sbcl:debian-stretch

latest: latest-alpine latest-debian

version:
	@echo $(SBCL_VERSION)

.PHONY: all alpine alpine-3.7 latest-alpine debian debian-stretch latest-debian latest version
