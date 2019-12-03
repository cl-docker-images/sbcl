FROM alpine:3.10

LABEL maintainer="etimmons@mit.edu"

COPY patches/ /usr/local/src/sbcl-patches/

ENV SBCL_VERSION=1.5.7

WORKDIR /usr/local/src/

# hadolint ignore=DL3003,DL3018
RUN set -x \
    && get_arch_code() { \
         case "$(uname -m)" in \
           x86_64) echo "x86-64";; \
           armv7l) echo "armhf";; \
           aarch64) echo "arm64";; \
           *) exit 1;; \
         esac \
       } \
    && get_sbcl_binary_version() { \
         case "$(get_arch_code)" in \
           x86-64) echo "1.5.7";; \
           armhf) echo "1.4.11";; \
           arm64) echo "1.4.2";; \
         esac \
       } \
    && import_key() { \
         gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys "$1" \
         || gpg --batch --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys "$1" \
         || gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "$1" \
         || gpg --batch --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys "$1" \
         || gpg --batch --keyserver pgp.mit.edu --recv-keys "$1"; \
       } \
    && install_glibc() { \
         curl -L https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub > /etc/apk/keys/sgerrand.rsa.pub \
         && curl -L https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.30-r0/glibc-2.30-r0.apk > glibc-2.30-r0.apk \
         && apk add --no-cache glibc-2.30-r0.apk; \
       } \
    && remove_glibc() { \
         apk del --no-cache glibc \
         && rm -rf /etc/apk/keys/sgerrand.rsa.pub \
         && rm -rf glibc-2.30-r0.apk; \
    } \
    && download_and_validate_hashes() { \
         curl -L "https://downloads.sourceforge.net/project/sbcl/sbcl/${1}/sbcl-${1}-crhodes.asc" > "sbcl-${1}-crhodes.asc" \
         && gpg --batch --verify "sbcl-${1}-crhodes.asc" \
         && gpg --batch --decrypt "sbcl-${1}-crhodes.asc" > "sbcl-${1}-crhodes.txt"; \
       } \
    && download_and_unpack_binary() { \
         url="https://downloads.sourceforge.net/project/sbcl/sbcl/${1}/sbcl-${1}-$(get_arch_code)-linux-binary.tar.bz2" \
         && curl -L "$url" > "sbcl-${1}-$(get_arch_code)-linux-binary.tar.bz2" \
         && bunzip2 "sbcl-${1}-$(get_arch_code)-linux-binary.tar.bz2" \
         && if grep "sbcl-${1}-$(get_arch_code)-linux-binary.tar" "sbcl-${1}-crhodes.txt" > "${1}-sum-file.txt"; then sha256sum -c "${1}-sum-file.txt"; fi \
         && tar xf "sbcl-${1}-$(get_arch_code)-linux-binary.tar" \
         && rm -rf "sbcl-${1}-$(get_arch_code)-linux-binary.tar"; \
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
    && SBCL_BINARY_VERSION="$(get_sbcl_binary_version)" \
    && export SBCL_BINARY_VERSION \
    && apk add --no-cache ca-certificates curl openssl make gcc musl-dev linux-headers gnupg \
    && GNUPGHOME="$(mktemp -d)" \
    && export GNUPGHOME \
    && export CRHODES_KEY=D6839CA0A67F74D9DFB70922EBD595A9100D63CD \
    && import_key "$CRHODES_KEY" \
    && download_and_validate_hashes "$SBCL_BINARY_VERSION" \
    && download_and_validate_hashes "$SBCL_VERSION" \
    && install_glibc \
    && download_and_unpack_binary "$SBCL_BINARY_VERSION" \
    && download_and_build_source "$SBCL_VERSION" "/usr/local/src/sbcl-${SBCL_BINARY_VERSION}-$(get_arch_code)-linux/run-sbcl.sh" \
    && remove_glibc \
    && mv sbcl-patches /tmp \
    && rm -rf "$GNUPGHOME" ./* \
    && mv /tmp/sbcl-patches . \
    && apk del --no-cache ca-certificates curl openssl make gcc musl-dev linux-headers gnupg \
    && sbcl --version

WORKDIR /

ENTRYPOINT ["sbcl"]
