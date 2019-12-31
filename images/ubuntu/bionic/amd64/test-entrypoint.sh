#!/bin/sh

set -e

SBCL_BINARY_ARCH_CODE=x86-64
SBCL_BINARY_VERSION=1.5.5

git clone https://git.code.sf.net/p/sbcl/sbcl sbcl
cd sbcl

for p in /usr/local/src/sbcl-patches/*.patch; do
    patch -p1 < "$p" || exit 1
done

sh make.sh "/usr/local/src/sbcl-${SBCL_BINARY_VERSION}-$SBCL_BINARY_ARCH_CODE-linux/run-sbcl.sh"
cd tests/
sh run-tests.sh
