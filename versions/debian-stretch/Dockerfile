FROM debian:stretch as builder

# Install build requirements
RUN apt-get update \
    && apt-get install -y sbcl build-essential zlib1g-dev

ARG SBCL_VERSION

ADD https://downloads.sourceforge.net/project/sbcl/sbcl/${SBCL_VERSION}/sbcl-${SBCL_VERSION}-source.tar.bz2 /build/sbcl-${SBCL_VERSION}.tar.bz2


WORKDIR /build
RUN tar xf sbcl-${SBCL_VERSION}.tar.bz2 \
    && cd sbcl-${SBCL_VERSION}/ \
    && ./make.sh --fancy --prefix=/usr/local/ \
    && ./install.sh

FROM debian:stretch

LABEL maintainer="etimmons@mit.edu"

COPY --from=builder /usr/local/bin/sbcl /usr/local/bin/sbcl
COPY --from=builder /usr/local/lib/sbcl /usr/local/lib/sbcl

CMD ["sbcl"]
