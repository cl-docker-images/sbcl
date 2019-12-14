#!/bin/bash
#-*- sh-basic-offset: 2; -*-
set -ex

if [ "$1" != "build" ] && [ "$1" != "nonbuild" ]; then
  echo "First argument must be build or nonbuild"
  exit 1
fi

. scripts/helpers.bash

build_os_version_arch() {
  local image_variant
  local os
  local os_version
  local arch
  local docker_file
  local idfile
  local image_name
  local image_id
  local image_digest

  image_variant="$1"
  os="$2"
  os_version="$3"
  arch="$4"
  idfile="$(mktemp)"
  image_name="$(versioned_repo)-$(os_version_string "$os" "$os_version")-$arch"

  if [ "$image_variant" = "build" ]; then
    docker_file="$os/$os_version/$arch/Dockerfile.build"
    image_name="$image_name-build"
  else
    docker_file="$os/$os_version/$arch/Dockerfile"
  fi


  docker_build_for_arch "$arch" -t "$image_name" -f "$docker_file" "--iidfile=$idfile" "$os/$os_version/$arch"

  image_id=$(cat "$idfile")
  image_digest=$(docker_for_arch "$arch" inspect -f "{{(index .RepoDigests 0)}}" "$image_id")
  rm "$idfile"
  yq w -i build/image-ids.yaml "$os.\"$os_version\".$arch.$image_variant" "$image_digest"
}

build_all_oses() {
  mkdir -p build
  if [ ! -f "build/image-ids.yaml" ]; then
    echo "---" >> build/image-ids.yaml
  fi

  run_for_every_tuple "build_os_version_arch" "$@"
}

build_all_oses "$1"
