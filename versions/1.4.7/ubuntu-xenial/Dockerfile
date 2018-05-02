FROM ubuntu:xenial

LABEL maintainer="etimmons@mit.edu"

ENV SBCL_VERSION=1.4.7

RUN set -x \
    && mkdir /build \
    && cd /build \
    && apt-get update \
    && apt-get upgrade \
    && apt-get install -y sbcl build-essential zlib1g-dev gnupg wget ca-certificates\
    && wget https://downloads.sourceforge.net/project/sbcl/sbcl/${SBCL_VERSION}/sbcl-${SBCL_VERSION}-source.tar.bz2 \
    && wget https://downloads.sourceforge.net/project/sbcl/sbcl/${SBCL_VERSION}/sbcl-${SBCL_VERSION}-crhodes.asc \
    && export GNUPGHOME="$(mktemp -d)" \
    && export CRHODES_KEY=D6839CA0A67F74D9DFB70922EBD595A9100D63CD \
    && (gpg --keyserver ha.pool.sks-keyservers.net --recv-keys ${CRHODES_KEY} \
       || gpg --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys ${CRHODES_KEY} \
       || gpg --keyserver keyserver.ubuntu.com --recv-keys ${CRHODES_KEY} \
       || gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys ${CRHODES_KEY} \
       || gpg --keyserver pgp.mit.edu --recv-keys ${CRHODES_KEY}) \
    && gpg --batch --verify sbcl-${SBCL_VERSION}-crhodes.asc \
    && bunzip2 /build/sbcl-${SBCL_VERSION}-source.tar.bz2 \
    && grep sbcl-${SBCL_VERSION}-source.tar sbcl-${SBCL_VERSION}-crhodes.asc > sum-file.txt \
    && sha256sum -c sum-file.txt \
    && rm -rf "$GNUPGHOME" sbcl-${SBCL_VERSION}-crhodes.asc sum-file.txt \
    && tar xf sbcl-${SBCL_VERSION}-source.tar \
    && cd sbcl-${SBCL_VERSION}/ \
    && ./make.sh --fancy --prefix=/usr/local/ \
    && ./install.sh \
    && cd / \
    && rm -rf /build \
    && apt-get remove -y sbcl build-essential zlib1g-dev wget ca-certificates \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

CMD ["sbcl"]
