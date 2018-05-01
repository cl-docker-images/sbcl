#!/bin/sh

if [ "x$TRAVIS_BRANCH" = "xrelease" ]; then
    VERSION=$(make version)
    docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD
    docker push daewok/sbcl:${VERSION}-alpine-3.7
    docker push daewok/sbcl:alpine-3.7
    docker push daewok/sbcl:alpine
fi
