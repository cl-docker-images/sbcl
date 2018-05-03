# SBCL Docker Images [![Build Status](https://travis-ci.org/daewok/docker-sbcl.svg?branch=master)](https://travis-ci.org/daewok/docker-sbcl)

This repo contains Dockerfiles for SBCL builds on a variety of base images.

To build all images, just run:

    make

The release branch is used to automatically push images to Docker hub.

In all these images, SBCL is built with threading and compression support.
