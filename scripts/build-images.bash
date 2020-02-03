#!/bin/bash
#-*- sh-basic-offset: 2; -*-
set -ex

if [ "$1" != "build" ] && [ "$1" != "nonbuild" ] && [ "$1" != "test" ]; then
  echo "First argument must be build, nonbuild, or test"
  exit 1
fi

. scripts/helpers.bash

build_os_version_arch() {
  local image_variant
  local os
  local os_version
  local arch
  local docker_file
  local image_name

  image_variant="$1"
  os="$2"
  os_version="$3"
  arch="$4"
  image_name="$(versioned_repo)-$(os_version_string "$os" "$os_version")-$arch"

  if [ "$image_variant" = "build" ]; then
    docker_file="images/$os/$os_version/$arch/Dockerfile.build"
    image_name="$image_name-build"
  elif [ "$image_variant" = "test" ]; then
    docker_file="images/$os/$os_version/$arch/Dockerfile.test"
    image_name="$image_name-test"
  else
    docker_file="images/$os/$os_version/$arch/Dockerfile"
  fi


  docker_build_for_arch "$arch" -t "$image_name" -f "$docker_file" "images/$os/$os_version/$arch"
}

build_all_oses() {
  mkdir -p build
  if [ ! -f "build/image-ids.yaml" ]; then
    echo "---" >> build/image-ids.yaml
  fi

  run_for_every_tuple "build_os_version_arch" "$@"
}

build_all_oses "$1"
