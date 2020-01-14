#! /bin/bash
#-*- sh-basic-offset: 2; -*-

set -ex

. scripts/helpers.bash

export_digest() {
  local image_variant
  local os
  local os_version
  local arch
  local digest
  local var_name

  image_variant="$1"
  os="$2"
  os_version="$3"
  arch="$4"
  image_name="$(versioned_repo)-$(os_version_string "$os" "$os_version")-$arch"

  if [ "$image_variant" = "build" ]; then
    image_name="$image_name-build"
  fi

  digest="$(docker_for_arch "$arch" inspect -f "{{(index .RepoDigests 0)}}" "$image_name")"

  var_name="${os}_${os_version}_${arch}_${image_variant}_digest"
  var_name="${var_name//./_}"
  var_name="${var_name^^}"
  eval "$var_name=\"$digest\""
  export "${var_name?}"
}

export SBCL_VERSION

run_for_every_tuple export_digest nonbuild
run_for_every_tuple export_digest build

mkdir -p manifests

if [ "$(ls -A manifests)" ]; then
  echo "manifests folder MUST be empty"
  exit 1
fi

for i in manifest-templates/* ; do
  envsubst < "$i" > "manifests/$(basename "$i")"
done
