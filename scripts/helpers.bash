#!/bin/bash
#-*- sh-basic-offset: 2; -*-

export DOCKER_CONTENT_TRUST=1

docker_have_context_for_arch() {
  [ -n "${CONTEXTS[$1]}" ]
}

docker_for_arch() {
  local context
  context=${CONTEXTS[$1]}

  if [ -n "$context" ]; then
    context="--context=$context"
  fi

  shift

  docker "$context" "$@"
}

docker_build_for_arch() {
  local platform
  local arch
  arch="$1"
  platform=${ARCH_MAP[$arch]}

  if [ -z "$platform" ]; then
    echo "Unknown arch $arch"
    exit 1
  fi
  shift

  docker_for_arch "$arch" build --pull --platform "$platform" "$@"
}

versioned_repo() {
  echo "$REPO:$SBCL_VERSION"
}

os_version_string() {
  if [ "$1" = "alpine" ]; then
    echo "$1$2"
  else
    echo "$1-$2"
  fi
}

run_for_every_tuple() {
  local os
  local os_version
  local arch
  local fun
  fun="$1"
  shift

  for os_dir in images/*; do
    os="$(basename "$os_dir")"
    for os_version_dir in "images/$os/"*; do
      os_version="$(basename "$os_version_dir")"
      for arch_dir in "images/$os/$os_version/"*; do
        arch="$(basename "$arch_dir")"
        if docker_have_context_for_arch "$arch"; then
          "$fun" "$@" "$os" "$os_version" "$arch"
        fi
      done
    done
  done
}

. .env-defaults
. .env
