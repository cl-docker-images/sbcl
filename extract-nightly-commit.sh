#!/bin/sh

set -e

grep -e "^ENV SBCL_COMMIT" nightly/buster/Dockerfile | cut -d" " -f 3
