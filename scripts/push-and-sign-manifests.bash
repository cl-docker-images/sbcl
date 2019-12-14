#! /bin/bash
#-*- sh-basic-offset: 2; -*-

# This was inspired heavily by
# https://github.com/linuxkit/linuxkit/blob/master/tools/alpine/push-manifest.sh

set -e

if [ -z "$NOTARY_DELEGATION_PASSPHRASE" ]; then
  echo "You must set NOTARY_DELEGATION_PASSPHRASE"
  exit 1
fi

if [ -z "$DOCKER_USERNAME" ]; then
  echo "You must set DOCKER_USERNAME"
  exit 1
fi

if [ -z "$DOCKER_PASSWORD" ]; then
  echo "You must set DOCKER_PASSWORD"
  exit 1
fi

sign_manifest() {
  tagged_name="$(yq r "$1" image)"
  tag="${tagged_name#*:}"
  repo="${tagged_name%:*}"
  gun="docker.io/$repo"

  sha256=$(echo "$2" | cut -d' ' -f2 | cut -d':' -f2)
  size=$(echo "$2" | cut -d' ' -f3)

  notary_command="notary -s https://notary.docker.io -d $HOME/.docker/trust addhash -p $gun $tag $size --sha256 $sha256 -r targets/releases"
  echo '
  spawn '"$notary_command"'
  set pid [exp_pid]
  set timeout 60
  expect {
    timeout {
      puts "Expected username prompt"
      exec kill -9 $pid
      exit 1
    }
    "username: " {
      send "'"$DOCKER_USERNAME"'\n"
    }
  }
  expect {
    timeout {
      puts "Expected password prompt"
      exec kill -9 $pid
      exit 1
    }
    "password: " {
      send "'"$DOCKER_PASSWORD"'\n"
    }
  }
  expect {
    timeout {
      puts "Expected eof"
      exec kill -9 $pid
      exit 1
    }
    eof {
    }
  }
  set waitval [wait -i $spawn_id]
  set exval [lindex $waitval 3]
  exit $exval
  ' | expect -f -
}

for i in manifests/* ; do
  OUT="$(manifest-tool push from-spec "$i")"
  sign_manifest "$i" "$OUT"
done

# notary publish -s https://notary.docker.io -d ~/.docker/trust docker.io/daewok/sbcl
