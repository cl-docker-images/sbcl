FROM ubuntu:disco

LABEL maintainer="etimmons@mit.edu"

ENV SBCL_VERSION=1.5.7

WORKDIR /usr/local/src/

# hadolint ignore=DL3003,DL3008
RUN set -x \
    && apt-get update \
    && apt-get install -y --no-install-recommends curl gnupg ca-certificates make \
    && GNUPGHOME="$(mktemp -d)" \
    && export GNUPGHOME \
    && export CRHODES_KEY=D6839CA0A67F74D9DFB70922EBD595A9100D63CD \
    && (gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys ${CRHODES_KEY} \
       || gpg --batch --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys ${CRHODES_KEY} \
       || gpg --batch --keyserver keyserver.ubuntu.com --recv-keys ${CRHODES_KEY} \
       || gpg --batch --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys ${CRHODES_KEY} \
       || gpg --batch --keyserver pgp.mit.edu --recv-keys ${CRHODES_KEY}) \
    && curl -L https://downloads.sourceforge.net/project/sbcl/sbcl/${SBCL_VERSION}/sbcl-${SBCL_VERSION}-crhodes.asc > sbcl-${SBCL_VERSION}-crhodes.asc \
    && gpg --batch --verify sbcl-${SBCL_VERSION}-crhodes.asc \
    && gpg --batch --decrypt sbcl-${SBCL_VERSION}-crhodes.asc > sbcl-${SBCL_VERSION}-crhodes.txt \
    && get_arch_code() { \
        case "$(uname -m)" in \
           x86_64) echo "x86-64";; \
           aarch64) echo "arm64";; \
           *) exit 1;; \
         esac \
       } \
    && get_binary_url() { \
         echo "https://downloads.sourceforge.net/project/sbcl/sbcl/${SBCL_VERSION}/sbcl-${SBCL_VERSION}-$(get_arch_code)-linux-binary.tar.bz2"; \
       } \
    && download_binary() { \
         set -e; \
         url=$(get_binary_url); \
         curl -L "$url" > sbcl-${SBCL_VERSION}-$(get_arch_code)-linux-binary.tar.bz2; \
         bunzip2 sbcl-${SBCL_VERSION}-$(get_arch_code)-linux-binary.tar.bz2; \
         grep sbcl-${SBCL_VERSION}-$(get_arch_code)-linux-binary.tar sbcl-${SBCL_VERSION}-crhodes.txt > sum-file.txt; \
         sha256sum -c sum-file.txt; \
         rm -rf sbcl-${SBCL_VERSION}-crhodes.asc sbcl-${SBCL_VERSION}-crhodes.txt sum-file.txt; \
         tar xf sbcl-${SBCL_VERSION}-$(get_arch_code)-linux-binary.tar; \
         (cd sbcl-${SBCL_VERSION}-$(get_arch_code)-linux/ && sh install.sh); \
         rm -rf sbcl-${SBCL_VERSION}-$(get_arch_code)-linux-binary.tar sbcl-${SBCL_VERSION}-$(get_arch_code)-linux/; \
       } \
    && download_and_build_source() { \
         set -e; \
         curl -L https://downloads.sourceforge.net/project/sbcl/sbcl/${SBCL_VERSION}/sbcl-${SBCL_VERSION}-source.tar.bz2 > sbcl-${SBCL_VERSION}-source.tar.bz2; \
         bunzip2 sbcl-${SBCL_VERSION}-source.tar.bz2; \
         grep sbcl-${SBCL_VERSION}-source.tar sbcl-${SBCL_VERSION}-crhodes.txt > sum-file.txt; \
         sha256sum -c sum-file.txt; \
         rm -rf sbcl-${SBCL_VERSION}-crhodes.asc sbcl-${SBCL_VERSION}-crhodes.txt sum-file.txt; \
         tar xf sbcl-${SBCL_VERSION}-source.tar; \
         apt-get install -y --no-install-recommends sbcl build-essential; \
         cd sbcl-${SBCL_VERSION}/; \
         sh make.sh; \
         sh install.sh; \
         cd /usr/local/src; \
         rm -rf sbcl-${SBCL_VERSION}-source.tar sbcl-${SBCL_VERSION}; \
         apt-get remove -y sbcl build-essential; \
       } \
    && if curl -fIL $(get_binary_url); then \
         download_binary; \
       else \
         download_and_build_source; \
       fi \
    && rm -rf "$GNUPGHOME" \
    && apt-get remove -y curl gnupg ca-certificates make \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /

ENTRYPOINT ["sbcl"]
