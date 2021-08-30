#!/bin/sh

set -e

grep -e "^ENV SBCL_COMMIT" nightly/bullseye/Dockerfile | cut -d" " -f 3
