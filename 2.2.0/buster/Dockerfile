#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "update.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#
FROM buildpack-deps:buster

ENV SBCL_VERSION 2.2.0
ENV SBCL_SIGNING_KEY D6839CA0A67F74D9DFB70922EBD595A9100D63CD

WORKDIR /usr/local/src/

# hadolint ignore=DL3003,DL3008
RUN set -x \
    && case "$(dpkg --print-architecture)" in \
    armhf) SBCL_ARCH=arm; SBCL_BINARY_ARCH_CODE=armhf; SBCL_BINARY_VERSION=1.4.11;; \
    arm64) SBCL_ARCH=arm64; SBCL_BINARY_ARCH_CODE=arm64; SBCL_BINARY_VERSION=1.4.2;; \
    # Limit to 1.5.5 because that's when the glibc version used to build was bumped
    amd64) SBCL_ARCH=x86-64; SBCL_BINARY_ARCH_CODE=x86-64; SBCL_BINARY_VERSION=1.5.5;; \
    *) echo "Unknown arch" >&2; exit 1;; \
    esac \
    && export SBCL_ARCH \
    && export SBCL_BINARY_ARCH_CODE \
    && export SBCL_BINARY_VERSION \
    && download_and_validate_hashes() { \
         curl -fsSL "https://downloads.sourceforge.net/project/sbcl/sbcl/${1}/sbcl-${1}-crhodes.asc" > "sbcl-${1}-crhodes.asc" \
         && gpg --batch --verify "sbcl-${1}-crhodes.asc" \
         && gpg --batch --decrypt "sbcl-${1}-crhodes.asc" > "sbcl-${1}-crhodes.txt"; \
       } \
    && download_and_unpack_binary() { \
         url="https://downloads.sourceforge.net/project/sbcl/sbcl/${1}/sbcl-${1}-$SBCL_BINARY_ARCH_CODE-linux-binary.tar.bz2" \
         && curl -fsSL "$url" > "sbcl-${1}-$SBCL_BINARY_ARCH_CODE-linux-binary.tar.bz2" \
         && bunzip2 "sbcl-${1}-$SBCL_BINARY_ARCH_CODE-linux-binary.tar.bz2" \
         && if grep "sbcl-${1}-$SBCL_BINARY_ARCH_CODE-linux-binary.tar" "sbcl-${1}-crhodes.txt" > "${1}-sum-file.txt"; then sha256sum -c "${1}-sum-file.txt"; fi \
         && tar xf "sbcl-${1}-$SBCL_BINARY_ARCH_CODE-linux-binary.tar" \
         && rm -rf "sbcl-${1}-$SBCL_BINARY_ARCH_CODE-linux-binary.tar"; \
       } \
    && download_source() { \
        url="https://downloads.sourceforge.net/project/sbcl/sbcl/${1}/sbcl-${1}-source.tar.bz2" \
         && curl -fsSL "$url" > "sbcl-${1}-source.tar.bz2" \
         && bunzip2 "sbcl-${1}-source.tar.bz2" \
         && grep "sbcl-${1}-source.tar" "sbcl-${1}-crhodes.txt" > "${1}-sum-file.txt" \
         && sha256sum -c "${1}-sum-file.txt" \
         && tar xf "sbcl-${1}-source.tar" \
         && mv "sbcl-$1" "sbcl"; \
       } \
    && build_and_install_source() { \
         cd "sbcl/" \
         # Remove the hardcoding of armv5 as target arch. Use the default
         # provided by the base image.
         && sed -i -e "s/CFLAGS += -marm -march=armv5/CFLAGS += -marm/" src/runtime/Config.arm-linux \
         && sh make.sh "--xc-host=${1}" --fancy \
         && sh install.sh \
         && sh clean.sh \
         && cd /usr/local/src; \
       } \
    && GNUPGHOME="$(mktemp -d)" \
    && export GNUPGHOME \
    && gpg --batch --keyserver keyserver.ubuntu.com --recv-keys ${SBCL_SIGNING_KEY} \
    && download_and_validate_hashes "$SBCL_BINARY_VERSION" \
    && download_and_validate_hashes "$SBCL_VERSION" \
    && download_and_unpack_binary "$SBCL_BINARY_VERSION" \
    && download_source "$SBCL_VERSION" \
    && build_and_install_source "/usr/local/src/sbcl-${SBCL_BINARY_VERSION}-$SBCL_BINARY_ARCH_CODE-linux/run-sbcl.sh" \
    && rm -rf "$GNUPGHOME" "$SBCL_BINARY_VERSION-sum-file.txt" "$SBCL_VERSION-sum-file.txt" "sbcl-$SBCL_BINARY_VERSION-crhodes."* "sbcl-$SBCL_VERSION-crhodes."*  "sbcl-$SBCL_VERSION-source.tar" "sbcl-$SBCL_BINARY_VERSION-$SBCL_BINARY_ARCH_CODE-linux" \
    && sbcl --version

# Add the Quicklisp installer.
WORKDIR /usr/local/share/common-lisp/source/quicklisp/

ENV QUICKLISP_SIGNING_KEY D7A3489DDEFE32B7D0E7CC61307965AB028B5FF7

RUN set -x \
    && curl -fsSL "https://beta.quicklisp.org/quicklisp.lisp" > quicklisp.lisp \
    && curl -fsSL "https://beta.quicklisp.org/quicklisp.lisp.asc" > quicklisp.lisp.asc \
    && GNUPGHOME="$(mktemp -d)" \
    && export GNUPGHOME \
    && gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "${QUICKLISP_SIGNING_KEY}" \
    && gpg --batch --verify "quicklisp.lisp.asc" "quicklisp.lisp" \
    && rm quicklisp.lisp.asc \
    && rm -rf "$GNUPGHOME"

# Add the script to trivially install Quicklisp
COPY install-quicklisp /usr/local/bin/install-quicklisp

# Install cl-launch and rlwrap. In the next release, move this up so that all
# images can share it.
# hadolint ignore=DL3008
RUN set -x \
    && apt-get update \
    && apt-get install --no-install-recommends -y cl-launch rlwrap \
    && rm -rf /var/lib/apt/lists/*

# Add the entrypoint
WORKDIR /

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["sbcl"]
