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

latest: latest-alpine

version:
	@echo $(SBCL_VERSION)

.PHONY: all alpine alpine-3.7 latest-alpine latest version
