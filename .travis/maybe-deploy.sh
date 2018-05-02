#!/bin/sh

if [ "x$TRAVIS_BRANCH" = "xrelease" ]; then
    docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD

    TAGS=$(docker images daewok/sbcl | tail -n +2 | tr -s ' ' | cut -d ' ' -f 2)
    for tag in ${TAGS}; do
        docker push daewok/sbcl:${tag}
    done

fi
