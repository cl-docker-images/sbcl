FROM alpine:3.9

LABEL maintainer="etimmons@mit.edu"

COPY patches/ /usr/local/src/sbcl-patches/

ENV SBCL_VERSION=1.5.7

WORKDIR /usr/local/src/

# hadolint ignore=DL3003,DL3018,DL4006
RUN set -x \
    && apk add --no-cache ca-certificates openssl make gcc gmp-dev g++ \
                          libffi-dev musl-dev gc gc-dev linux-headers gnupg ecl ecl-dev \
    && wget https://downloads.sourceforge.net/project/sbcl/sbcl/${SBCL_VERSION}/sbcl-${SBCL_VERSION}-source.tar.bz2 \
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
    && bunzip2 sbcl-${SBCL_VERSION}-source.tar.bz2 \
    && gpg --batch --decrypt sbcl-${SBCL_VERSION}-crhodes.asc > sbcl-${SBCL_VERSION}-crhodes.txt \
    && grep sbcl-${SBCL_VERSION}-source.tar sbcl-${SBCL_VERSION}-crhodes.txt > sum-file.txt \
    && sha256sum -c sum-file.txt \
    && rm -rf "$GNUPGHOME" sbcl-${SBCL_VERSION}-crhodes.asc sbcl-${SBCL_VERSION}-crhodes.txt sum-file.txt \
    && tar xf sbcl-${SBCL_VERSION}-source.tar \
    && cd sbcl-${SBCL_VERSION}/ \
    && for p in /usr/local/src/sbcl-patches/*.patch; do patch -p1 < "$p" || exit 1; done \
    && sh make.sh --xc-host=/usr/bin/ecl \
    && sh install.sh \
    && cd /usr/local/src/ \
    && rm -rf sbcl-${SBCL_VERSION}-source.tar sbcl-${SBCL_VERSION} \
    && apk del --no-cache ca-certificates gcc make linux-headers musl-dev gnupg openssl gc gc-dev libffi-dev gmp-dev ecl ecl-dev g++

WORKDIR /

ENTRYPOINT ["sbcl"]
