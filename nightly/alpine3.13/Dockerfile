#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "update.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#
FROM alpine:3.13

ENV SBCL_COMMIT 2562793b3e88fb60fa62db863b21ccaf7cbc9cad
ENV SBCL_VERSION 2.1.2.39-2562793
ENV SBCL_SIGNING_KEY D6839CA0A67F74D9DFB70922EBD595A9100D63CD

WORKDIR /usr/local/src/

# hadolint ignore=DL3003,DL3018
RUN set -x \
    && case "$(cat /etc/apk/arch)" in \
    # We use ECL to build because the version of SBCL in the edge repo doesn't
    # work for armv7 (edge has updated musl libc incompatibly).
    armv7) \
      SBCL_ARCH=arm; \
      if grep "3.13" /etc/issue 2>/dev/null >/dev/null ; then \
        HOST_LISP="sbcl"; \
      else \
        HOST_LISP="ecl"; \
        ECL_VERSION=20.4.24; \
        export ECL_VERSION; \
      fi \
      ;; \
    aarch64) SBCL_ARCH=arm64; HOST_LISP="sbcl";; \
    x86_64) SBCL_ARCH=x86-64; HOST_LISP="sbcl";; \
    *) echo "Unknown arch" >&2; exit 1;; \
    esac \
    && export SBCL_ARCH \
    && download_source() { \
        url="https://github.com/sbcl/sbcl/archive/$1.tar.gz" \
         && curl -fsSL "$url" > "sbcl-${1}.tar.gz" \
         && tar xf "sbcl-${1}.tar.gz"; \
       } \
    && build_and_install_source() { \
         cd "sbcl-${1}/" \
         && echo "\"$SBCL_VERSION\"" > version.lisp-expr \
         # Remove the hardcoding of armv5 as target arch. Use the default
         # provided by the base image.
         && sed -i -e "s/CFLAGS += -marm -march=armv5/CFLAGS += -marm/" src/runtime/Config.arm-linux \
         && sh make.sh "--xc-host=${2}" \
         && sh install.sh \
         && cd /usr/local/src; \
       } \
    && if [ "$HOST_LISP" = "ecl" ]; then \
         apk add --no-cache ca-certificates curl openssl make gcc musl-dev linux-headers \
                            gmp-dev libffi-dev \
         && curl -fsSL https://common-lisp.net/project/ecl/static/files/release/ecl-$ECL_VERSION.tgz > ecl-$ECL_VERSION.tgz \
         && echo "4c127e0d6a99e38f3a926135ae92d92899058c5a5e99b90f28d4a47b58d94ee89a958cfb4bfd2b9e6ad7b3c57867cd13119b2a4dd6bb1aa3bb5ec42a96bfa788  ecl-20.4.24.tgz" | sha512sum -c \
         && gunzip ecl-${ECL_VERSION}.tgz \
         && tar xf ecl-${ECL_VERSION}.tar \
         && (cd ecl-${ECL_VERSION} && ./configure --disable-manual && make -j "$(nproc)" && make install); \
       else \
         apk add --no-cache ca-certificates curl openssl make gcc musl-dev linux-headers \
         && apk add --no-cache sbcl --repository http://dl-3.alpinelinux.org/alpine/edge/community/; \
       fi \
    && download_source "$SBCL_COMMIT" \
    && build_and_install_source "$SBCL_COMMIT" "$HOST_LISP" \
    && if [ "$HOST_LISP" = "ecl" ]; then \
         (cd ecl-${ECL_VERSION} && make uninstall) \
         && apk del --no-cache ca-certificates curl openssl make gcc musl-dev linux-headers \
                               gmp-dev libffi-dev; \
       else \
         apk del --no-cache ca-certificates curl openssl make gcc musl-dev linux-headers sbcl; \
       fi \
    && sbcl --version

WORKDIR /

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["sbcl"]
