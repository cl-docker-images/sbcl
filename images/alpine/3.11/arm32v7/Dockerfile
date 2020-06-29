FROM alpine:3.11

LABEL maintainer="etimmons@mit.edu"

COPY patches/ /usr/local/src/sbcl-patches/

ENV SBCL_VERSION=2.0.6
ENV SBCL_ARCH=arm

WORKDIR /usr/local/src/

# hadolint ignore=DL3003,DL3018
RUN set -x \
    && import_key() { \
         gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys "$1" \
         || gpg --batch --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys "$1" \
         || gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "$1" \
         || gpg --batch --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys "$1" \
         || gpg --batch --keyserver pgp.mit.edu --recv-keys "$1"; \
       } \
    && download_and_validate_hashes() { \
         curl -L "https://downloads.sourceforge.net/project/sbcl/sbcl/${1}/sbcl-${1}-crhodes.asc" > "sbcl-${1}-crhodes.asc" \
         && gpg --batch --verify "sbcl-${1}-crhodes.asc" \
         && gpg --batch --decrypt "sbcl-${1}-crhodes.asc" > "sbcl-${1}-crhodes.txt"; \
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
    && apk add --no-cache ca-certificates curl openssl make gcc musl-dev linux-headers gnupg \
                          gmp-dev g++ libffi-dev \
    && apk add --no-cache sbcl --repository http://dl-3.alpinelinux.org/alpine/edge/testing/ \
    && GNUPGHOME="$(mktemp -d)" \
    && export GNUPGHOME \
    && export CRHODES_KEY=D6839CA0A67F74D9DFB70922EBD595A9100D63CD \
    && import_key "$CRHODES_KEY" \
    && download_and_validate_hashes "$SBCL_VERSION" \
    && download_source "$SBCL_VERSION" \
    && build_and_install_source "$SBCL_VERSION" "sbcl" \
    && mv sbcl-patches /tmp \
    && rm -rf "$GNUPGHOME" ./* \
    && mv /tmp/sbcl-patches . \
    && apk del --no-cache ca-certificates curl openssl make gcc musl-dev linux-headers gnupg \
                          gmp-dev g++ libffi-dev sbcl \
    && sbcl --version

WORKDIR /

ENTRYPOINT ["sbcl"]
