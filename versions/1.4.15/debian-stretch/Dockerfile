FROM debian:stretch

LABEL maintainer="etimmons@mit.edu"

ENV SBCL_VERSION=1.4.15

WORKDIR /usr/local/src/

# hadolint ignore=DL3003,DL3008
RUN set -x \
    && apt-get update \
    && apt-get install -y --no-install-recommends wget gnupg ca-certificates make dirmngr bzip2 \
    && wget https://downloads.sourceforge.net/project/sbcl/sbcl/${SBCL_VERSION}/sbcl-${SBCL_VERSION}-x86-64-linux-binary.tar.bz2 \
    && wget https://downloads.sourceforge.net/project/sbcl/sbcl/${SBCL_VERSION}/sbcl-${SBCL_VERSION}-crhodes.asc \
    && GNUPGHOME="$(mktemp -d)" \
    && export GNUPGHOME \
    && export CRHODES_KEY=D6839CA0A67F74D9DFB70922EBD595A9100D63CD \
    && (gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys ${CRHODES_KEY} \
       || gpg --batch --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys ${CRHODES_KEY} \
       || gpg --batch --keyserver keyserver.ubuntu.com --recv-keys ${CRHODES_KEY} \
       || gpg --batch --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys ${CRHODES_KEY} \
       || gpg --batch --keyserver pgp.mit.edu --recv-keys ${CRHODES_KEY}) \
    && gpg --batch --verify sbcl-${SBCL_VERSION}-crhodes.asc \
    && bunzip2 sbcl-${SBCL_VERSION}-x86-64-linux-binary.tar.bz2 \
    && grep sbcl-${SBCL_VERSION}-x86-64-linux-binary.tar sbcl-${SBCL_VERSION}-crhodes.asc > sum-file.txt \
    && sha256sum -c sum-file.txt \
    && rm -rf "$GNUPGHOME" sbcl-${SBCL_VERSION}-crhodes.asc sum-file.txt \
    && tar xf sbcl-${SBCL_VERSION}-x86-64-linux-binary.tar \
    && (cd sbcl-${SBCL_VERSION}-x86-64-linux/ && sh install.sh) \
    && rm -rf sbcl-${SBCL_VERSION}-x86-64-linux-binary.tar sbcl-${SBCL_VERSION}-x86-64-linux/ \
    && apt-get remove -y wget gnupg ca-certificates make dirmngr bzip2 \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /

ENTRYPOINT ["sbcl"]
