#!/bin/sh

set -e

cp -a /sbcl /sbcl-work
cd /sbcl-work

for p in /patches/*.patch; do
    [ -e "$p" ] || continue
    patch -p1 < "$p" || exit 1
done

sh make.sh "--xc-host=ecl"
cd tests/
sh run-tests.sh
