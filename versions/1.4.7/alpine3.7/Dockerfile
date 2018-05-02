FROM alpine:3.7

LABEL maintainer="etimmons@mit.edu"

COPY patches/musl-libc.patch /build/patches/musl-libc.patch

ENV SBCL_VERSION=1.4.7

RUN set -x && cd /build \
    && apk upgrade --no-cache \
    && apk add --no-cache ca-certificates openssl make gcc linux-headers musl-dev zlib-dev gnupg \
    && apk add --no-cache --repository http://dl-3.alpinelinux.org/alpine/edge/testing/ sbcl \
    && wget https://downloads.sourceforge.net/project/sbcl/sbcl/${SBCL_VERSION}/sbcl-${SBCL_VERSION}-source.tar.bz2 \
    && wget https://downloads.sourceforge.net/project/sbcl/sbcl/${SBCL_VERSION}/sbcl-${SBCL_VERSION}-crhodes.asc \
    && export GNUPGHOME="$(mktemp -d)" \
    && export CRHODES_KEY=D6839CA0A67F74D9DFB70922EBD595A9100D63CD \
    && (gpg --keyserver ha.pool.sks-keyservers.net --recv-keys ${CRHODES_KEY} \
       || gpg --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys ${CRHODES_KEY} \
       || gpg --keyserver keyserver.ubuntu.com --recv-keys ${CRHODES_KEY} \
       || gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys ${CRHODES_KEY} \
       || gpg --keyserver pgp.mit.edu --recv-keys ${CRHODES_KEY}) \
    && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys D6839CA0A67F74D9DFB70922EBD595A9100D63CD \
    && gpg --batch --verify sbcl-${SBCL_VERSION}-crhodes.asc \
    && bunzip2 /build/sbcl-${SBCL_VERSION}-source.tar.bz2 \
    && grep sbcl-${SBCL_VERSION}-source.tar sbcl-${SBCL_VERSION}-crhodes.asc > sum-file.txt \
    && sha256sum -c sum-file.txt \
    && rm -r "$GNUPGHOME" sbcl-${SBCL_VERSION}-crhodes.asc sum-file.txt \
    && tar xf sbcl-${SBCL_VERSION}-source.tar \
    && cd sbcl-${SBCL_VERSION}/ \
    && patch -i /build/patches/musl-libc.patch -p1 \
    && ./make.sh --fancy --prefix=/usr/local/ \
    && ./install.sh \
    && cd / \
    && rm -r /build \
    && apk del --no-cache sbcl gcc make linux-headers musl-dev zlib-dev gnupg openssl

CMD ["sbcl"]
