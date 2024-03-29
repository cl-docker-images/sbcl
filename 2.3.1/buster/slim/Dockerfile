#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "update.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#
FROM debian:buster

ENV SBCL_VERSION 2.3.1
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
         && tar xf "sbcl-${1}-source.tar"; \
       } \
    && build_and_install_source() { \
         cd "sbcl-${1}/" \
         # Remove the hardcoding of armv5 as target arch. Use the default
         # provided by the base image.
         && sed -i -e "s/CFLAGS += -marm -march=armv5/CFLAGS += -marm/" src/runtime/Config.arm-linux \
         # Old versions of SBCL choke. <https://sourceforge.net/p/sbcl/mailman/message/37640913/>
         && echo "(setf *debugger-hook* (lambda (c h) (declare (ignore h)) (let ((restart (find-restart 'continue c))) (when restart (invoke-restart restart)))))" > build-debugger-hook.lisp \
         && sh make.sh "--xc-host=${2}" \
         && sh install.sh \
         && rm build-debugger-hook.lisp \
         && cd /usr/local/src; \
       } \
    && apt-get update \
    && apt-get install -y --no-install-recommends curl gnupg ca-certificates make dirmngr bzip2 build-essential libzstd-dev \
    && GNUPGHOME="$(mktemp -d)" \
    && export GNUPGHOME \
    && gpg --batch --keyserver keyserver.ubuntu.com --recv-keys ${SBCL_SIGNING_KEY} \
    && download_and_validate_hashes "$SBCL_BINARY_VERSION" \
    && download_and_validate_hashes "$SBCL_VERSION" \
    && download_and_unpack_binary "$SBCL_BINARY_VERSION" \
    && download_source "$SBCL_VERSION" \
    && build_and_install_source "$SBCL_VERSION" "/usr/local/src/sbcl-${SBCL_BINARY_VERSION}-$SBCL_BINARY_ARCH_CODE-linux/run-sbcl.sh --load build-debugger-hook.lisp" \
    && rm -rf "$GNUPGHOME" ./* \
    && apt-get remove -y curl gnupg ca-certificates make dirmngr bzip2 build-essential libzstd-dev \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/* \
    && sbcl --version

WORKDIR /

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["sbcl"]
