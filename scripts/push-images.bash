#!/bin/bash
#-*- sh-basic-offset: 2; -*-
set -ex

if [ "$1" != "build" ] && [ "$1" != "nonbuild" ]; then
  echo "First argument must be build or nonbuild"
  exit 1
fi

. scripts/helpers.bash

push_os_version_arch() {
  local image_variant
  local os
  local os_version
  local arch
  local image_name

  image_variant="$1"
  os="$2"
  os_version="$3"
  arch="$4"

  image_name="$(versioned_repo)-$(os_version_string "$os" "$os_version")-$arch"

  if [ "$image_variant" = "build" ]; then
    image_name="$image_name-build"
  fi

  docker_for_arch "$arch" push "$image_name"
}

push_all_oses() {
  run_for_every_tuple "push_os_version_arch" "$@"
}

push_all_oses "$1"
