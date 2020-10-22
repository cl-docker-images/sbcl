FROM daewok/sbcl:2.0.6-alpine3.11-arm32v7 as prev-sbcl

FROM alpine:3.11

LABEL maintainer="etimmons@mit.edu"

COPY patches/ /usr/local/src/sbcl-patches/
ARG ref=master
ENV SBCL_REF=$ref
ENV SBCL_ARCH=x86-64

WORKDIR /usr/local/src/

COPY --from=prev-sbcl /usr/local/bin/sbcl /usr/bin/sbcl
COPY --from=prev-sbcl /usr/local/lib/sbcl /usr/lib/sbcl

# hadolint ignore=DL3003,DL3018
RUN set -x \
    && build_and_install_source() { \
         cd "sbcl/" \
         && for p in /usr/local/src/sbcl-patches/*.patch; do [ -e "$p" ] || continue; patch -p1 < "$p" || exit 1; done \
         && sh make.sh "--xc-host=${1}" \
         && sh install.sh \
         && cd /usr/local/src; \
       } \
    && apk add --no-cache ca-certificates curl openssl make gcc musl-dev linux-headers \
                          gmp-dev g++ libffi-dev patch git \
    && git clone https://github.com/sbcl/sbcl.git /usr/local/src/sbcl \
    && build_and_install_source "sbcl" \
    && mv sbcl-patches /tmp \
    && rm -rf ./* \
    && mv /tmp/sbcl-patches . \
    && rm -rf /usr/bin/sbcl /usr/lib/sbcl \
    && apk del --no-cache ca-certificates curl openssl make gcc musl-dev linux-headers \
                          gmp-dev g++ libffi-dev patch git \
    && sbcl --version

WORKDIR /

COPY docker-entrypoint /usr/local/bin/docker-entrypoint

ENTRYPOINT ["docker-entrypoint"]

CMD ["sbcl"]
