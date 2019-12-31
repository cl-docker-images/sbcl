#!/bin/sh

set -e

git clone https://git.code.sf.net/p/sbcl/sbcl sbcl
cd sbcl

for p in /usr/local/src/sbcl-patches/*.patch; do
    patch -p1 < "$p" || exit 1
done

sh make.sh "--xc-host=ecl"
cd tests/
sh run-tests.sh
