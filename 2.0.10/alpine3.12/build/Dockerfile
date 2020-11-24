#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "update.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#
FROM daewok/sbcl:2.0.10-alpine3.12

WORKDIR /usr/local/src/

RUN set -x \
    && apk add --no-cache ca-certificates openssl make gcc linux-headers musl-dev zlib-dev gnupg patch curl \
    && curl -fsSL "https://downloads.sourceforge.net/project/sbcl/sbcl/${SBCL_VERSION}/sbcl-${SBCL_VERSION}-source.tar.bz2" > "sbcl-${SBCL_VERSION}-source.tar.bz2" \
    && curl -fsSL "https://downloads.sourceforge.net/project/sbcl/sbcl/${SBCL_VERSION}/sbcl-${SBCL_VERSION}-crhodes.asc" > "sbcl-${SBCL_VERSION}-crhodes.asc" \
    && GNUPGHOME="$(mktemp -d)" \
    && export GNUPGHOME \
    && export CRHODES_KEY=D6839CA0A67F74D9DFB70922EBD595A9100D63CD \
    && gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys ${SBCL_SIGNING_KEY} \
    && gpg --batch --verify sbcl-${SBCL_VERSION}-crhodes.asc \
    && bunzip2 sbcl-${SBCL_VERSION}-source.tar.bz2 \
    && gpg --batch --decrypt sbcl-${SBCL_VERSION}-crhodes.asc > sbcl-${SBCL_VERSION}-crhodes.txt \
    && grep sbcl-${SBCL_VERSION}-source.tar sbcl-${SBCL_VERSION}-crhodes.txt > sum-file.txt \
    && sha256sum -c sum-file.txt \
    && rm -rf "$GNUPGHOME" sbcl-${SBCL_VERSION}-crhodes.asc sbcl-${SBCL_VERSION}-crhodes.txt sum-file.txt \
    && tar xf sbcl-${SBCL_VERSION}-source.tar \
    && rm -rf sbcl-${SBCL_VERSION}-source.tar \
    && apk del --no-cache gnupg openssl curl

WORKDIR /

COPY rebuild-sbcl /usr/local/bin/rebuild-sbcl
