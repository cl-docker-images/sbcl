#!/bin/sh

if [ "x$TRAVIS_BRANCH" = "xrelease" ]; then
    docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD

    TAGS=$(make alpine_tags)
    for tag in ${TAGS}; do
        docker push daewok/sbcl:${TAG}
    done

fi
