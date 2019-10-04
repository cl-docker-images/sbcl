FROM alpine:3.9

LABEL maintainer="etimmons@mit.edu"

COPY patches/ /usr/local/src/sbcl-patches/

ENV SBCL_VERSION=1.5.7

WORKDIR /usr/local/src/

# hadolint ignore=DL3003,DL3018,DL4006
RUN set -x \
    && export ECL_VERSION=16.1.3 \
    && apk add --no-cache ca-certificates openssl make gcc gmp-dev \
                          libffi-dev musl-dev gc gc-dev linux-headers gnupg \
    && wget https://common-lisp.net/project/ecl/static/files/release/ecl-${ECL_VERSION}.tgz \
    && echo "5d743f422f6bc24671abf4c739cde8273d08f056906a1ef8aed5145c703b6d52c7fa4b5e0be8c125f32240c20ce053007786bb3ae81cc34d47791f6fae0819c1  ecl-16.1.3.tgz" | sha512sum -c \
    && gunzip ecl-${ECL_VERSION}.tgz \
    && tar xf ecl-${ECL_VERSION}.tar \
    && (cd ecl-${ECL_VERSION} && ./configure --enable-boehm=system --prefix=/usr/local/ecl/ && make && make install) \
    && rm -rf ecl-${ECL_VERSION}.tar ecl-${ECL_VERSION} \
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
    && sh make.sh --xc-host=/usr/local/ecl/bin/ecl \
    && sh install.sh \
    && cd /usr/local/src/ \
    && rm -rf sbcl-${SBCL_VERSION}-source.tar sbcl-${SBCL_VERSION} /usr/local/ecl/ \
    && apk del --no-cache ca-certificates gcc make linux-headers musl-dev gnupg openssl gc gc-dev libffi-dev gmp-dev

WORKDIR /

ENTRYPOINT ["sbcl"]
