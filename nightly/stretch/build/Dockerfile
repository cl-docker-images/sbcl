#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "update.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#
FROM daewok/sbcl:nightly-stretch

WORKDIR /usr/local/src/

# hadolint ignore=DL3003,DL3008,SC2086
RUN set -x \
    && apt-get update \
    && apt-get install -y --no-install-recommends make zlib1g-dev gcc patch curl ca-certificates \
    && curl -fsSL "https://github.com/sbcl/sbcl/archive/$SBCL_COMMIT.tar.gz" > "sbcl-${SBCL_COMMIT}.tar.gz" \
    && tar xf sbcl-${SBCL_COMMIT}.tar.gz \
    && rm -rf sbcl-${SBCL_COMMIT}.tar.gz \
    && echo "\"$SBCL_VERSION\"" > sbcl-$SBCL_COMMIT/version.lisp-expr \
    && apt-get remove -y curl ca-certificates \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /

COPY rebuild-sbcl /usr/local/bin/rebuild-sbcl
