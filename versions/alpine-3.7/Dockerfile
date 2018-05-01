FROM alpine:edge as builder

# Install build requirements
RUN apk add --repository http://dl-3.alpinelinux.org/alpine/edge/testing/ sbcl \
    && apk add make gcc linux-headers musl-dev zlib-dev

COPY patches/ /build/patches/

ARG SBCL_VERSION

ADD https://downloads.sourceforge.net/project/sbcl/sbcl/${SBCL_VERSION}/sbcl-${SBCL_VERSION}-source.tar.bz2 /build/sbcl-${SBCL_VERSION}.tar.bz2


WORKDIR /build
RUN tar xf sbcl-${SBCL_VERSION}.tar.bz2 \
    && cd sbcl-${SBCL_VERSION}/ \
    && cat /build/patches/netdb-addition.h >> /usr/include/netdb.h \
    && patch -i /build/patches/*.patch -p1 \
    && ./make.sh --fancy --prefix=/usr/local/ \
    && ./install.sh

FROM alpine:3.7

COPY --from=builder /usr/local/bin/sbcl /usr/local/bin/sbcl
COPY --from=builder /usr/local/lib/sbcl /usr/local/lib/sbcl

CMD ["sbcl"]
