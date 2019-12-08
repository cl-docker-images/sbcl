FROM alpine:3.9

ARG TARGETARCH

LABEL maintainer="etimmons@mit.edu"

COPY patches/ /usr/local/src/sbcl-patches/

ENV SBCL_VERSION=1.5.9

WORKDIR /usr/local/src/

# hadolint ignore=DL3003,DL3018
RUN set -x \
    && get_arch_code() { \
         case "$TARGETARCH" in \
           amd64) echo "x86-64";; \
           arm64) echo "arm64";; \
           arm) echo "armhf";; \
           *) exit 1;; \
         esac \
      } \
    && get_sbcl_arch() { \
         case "$TARGETARCH" in \
           amd64) echo "x86-64";; \
           arm64) echo "arm64";; \
           arm) echo "arm";; \
           *) exit 1;; \
         esac \
      } \
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
    && download_and_build_source() { \
        url="https://downloads.sourceforge.net/project/sbcl/sbcl/${1}/sbcl-${1}-source.tar.bz2" \
         && curl -L "$url" > "sbcl-${1}-source.tar.bz2" \
         && bunzip2 "sbcl-${1}-source.tar.bz2" \
         && grep "sbcl-${1}-source.tar" "sbcl-${1}-crhodes.txt" > "${1}-sum-file.txt" \
         && sha256sum -c "${1}-sum-file.txt" \
         && tar xf "sbcl-${1}-source.tar" \
         && cd "sbcl-${1}/" \
         && for p in /usr/local/src/sbcl-patches/*.patch; do patch -p1 < "$p" || exit 1; done \
         && sh make.sh "--xc-host=${2}" \
         && sh install.sh \
         && cd /usr/local/src; \
       } \
    && SBCL_ARCH="$(get_sbcl_arch)" \
    && export SBCL_ARCH \
    && apk add --no-cache ca-certificates curl openssl make gcc musl-dev linux-headers gnupg ecl \
                          gmp-dev g++ libffi-dev musl-dev gc gc-dev linux-headers ecl-dev \
    && GNUPGHOME="$(mktemp -d)" \
    && export GNUPGHOME \
    && export CRHODES_KEY=D6839CA0A67F74D9DFB70922EBD595A9100D63CD \
    && import_key "$CRHODES_KEY" \
    && download_and_validate_hashes "$SBCL_VERSION" \
    && download_and_build_source "$SBCL_VERSION" "ecl" \
    && mv sbcl-patches /tmp \
    && rm -rf "$GNUPGHOME" ./* \
    && mv /tmp/sbcl-patches . \
    && apk del --no-cache ca-certificates curl openssl make gcc musl-dev linux-headers gnupg ecl \
                          gmp-dev g++ libffi-dev musl-dev gc gc-dev linux-headers ecl-dev \
    && sbcl --version

WORKDIR /

ENTRYPOINT ["sbcl"]
