FROM debian:stretch

LABEL maintainer="etimmons@mit.edu"

COPY patches/ /usr/local/src/sbcl-patches/

ENV SBCL_VERSION=2.0.9
ENV SBCL_ARCH=x86-64

WORKDIR /usr/local/src/

# hadolint ignore=DL3003,DL3008
RUN set -x \
    && SBCL_BINARY_ARCH_CODE="x86-64" \
    && export SBCL_BINARY_ARCH_CODE \
    && SBCL_BINARY_VERSION="1.5.5" \
    && export SBCL_BINARY_VERSION \
    && download_and_validate_hashes() { \
         curl -L "https://downloads.sourceforge.net/project/sbcl/sbcl/${1}/sbcl-${1}-crhodes.asc" > "sbcl-${1}-crhodes.asc" \
         && gpg --batch --verify "sbcl-${1}-crhodes.asc" \
         && gpg --batch --decrypt "sbcl-${1}-crhodes.asc" > "sbcl-${1}-crhodes.txt"; \
       } \
    && download_and_unpack_binary() { \
         url="https://downloads.sourceforge.net/project/sbcl/sbcl/${1}/sbcl-${1}-$SBCL_BINARY_ARCH_CODE-linux-binary.tar.bz2" \
         && curl -L "$url" > "sbcl-${1}-$SBCL_BINARY_ARCH_CODE-linux-binary.tar.bz2" \
         && bunzip2 "sbcl-${1}-$SBCL_BINARY_ARCH_CODE-linux-binary.tar.bz2" \
         && if grep "sbcl-${1}-$SBCL_BINARY_ARCH_CODE-linux-binary.tar" "sbcl-${1}-crhodes.txt" > "${1}-sum-file.txt"; then sha256sum -c "${1}-sum-file.txt"; fi \
         && tar xf "sbcl-${1}-$SBCL_BINARY_ARCH_CODE-linux-binary.tar" \
         && rm -rf "sbcl-${1}-$SBCL_BINARY_ARCH_CODE-linux-binary.tar"; \
       } \
    && download_source() { \
        url="https://downloads.sourceforge.net/project/sbcl/sbcl/${1}/sbcl-${1}-source.tar.bz2" \
         && curl -L "$url" > "sbcl-${1}-source.tar.bz2" \
         && bunzip2 "sbcl-${1}-source.tar.bz2" \
         && grep "sbcl-${1}-source.tar" "sbcl-${1}-crhodes.txt" > "${1}-sum-file.txt" \
         && sha256sum -c "${1}-sum-file.txt" \
         && tar xf "sbcl-${1}-source.tar"; \
       } \
    && build_and_install_source() { \
         cd "sbcl-${1}/" \
         && for p in /usr/local/src/sbcl-patches/*.patch; do [ -e "$p" ] || continue; patch -p1 < "$p" || exit 1; done \
         && sh make.sh "--xc-host=${2}" \
         && sh install.sh \
         && cd /usr/local/src; \
       } \
    && apt-get update \
    && apt-get install -y --no-install-recommends curl gnupg ca-certificates make dirmngr bzip2 build-essential patch \
    && GNUPGHOME="$(mktemp -d)" \
    && export GNUPGHOME \
    && export CRHODES_KEY=D6839CA0A67F74D9DFB70922EBD595A9100D63CD \
    && (gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys ${CRHODES_KEY} \
       || gpg --batch --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys ${CRHODES_KEY} \
       || gpg --batch --keyserver keyserver.ubuntu.com --recv-keys ${CRHODES_KEY} \
       || gpg --batch --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys ${CRHODES_KEY} \
       || gpg --batch --keyserver pgp.mit.edu --recv-keys ${CRHODES_KEY}) \
    && download_and_validate_hashes "$SBCL_BINARY_VERSION" \
    && download_and_validate_hashes "$SBCL_VERSION" \
    && download_and_unpack_binary "$SBCL_BINARY_VERSION" \
    && download_source "$SBCL_VERSION" \
    && build_and_install_source "$SBCL_VERSION" "/usr/local/src/sbcl-${SBCL_BINARY_VERSION}-$SBCL_BINARY_ARCH_CODE-linux/run-sbcl.sh" \
    && mv sbcl-patches /tmp \
    && rm -rf "$GNUPGHOME" ./* \
    && mv /tmp/sbcl-patches . \
    && apt-get remove -y curl gnupg ca-certificates make dirmngr bzip2 build-essential patch \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /

COPY docker-entrypoint /usr/local/bin/docker-entrypoint

ENTRYPOINT ["docker-entrypoint"]

CMD ["sbcl"]
