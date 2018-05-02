#!/bin/sh

if [ "x$TRAVIS_BRANCH" = "xrelease" ]; then
    docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD

    docker push $(docker images -q daewok/sbcl)

fi
