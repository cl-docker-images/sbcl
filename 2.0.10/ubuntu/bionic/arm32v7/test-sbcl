#!/bin/sh

set -e

SBCL_BINARY_ARCH_CODE=armhf
SBCL_BINARY_VERSION=1.4.11

cp -a /sbcl /sbcl-work
cd /sbcl-work

for p in /patches/*.patch; do
    [ -e "$p" ] || continue
    patch -p1 < "$p" || exit 1
done

sh make.sh "/usr/local/src/sbcl-${SBCL_BINARY_VERSION}-$SBCL_BINARY_ARCH_CODE-linux/run-sbcl.sh"
cd tests/
sh run-tests.sh
