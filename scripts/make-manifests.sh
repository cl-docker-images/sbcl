#! /bin/sh
#-*- sh-basic-offset: 2; -*-

if [ -z "$1" ]; then
  echo "Version number is required!"
  exit 1
fi

mkdir -p manifests

if [ "$(ls -A manifests)" ]; then
  echo "manifests folder MUST be empty"
  exit 1
fi

for i in manifest-templates/* ; do
  sed -e "s/VERSION/$1/g" "$i" > "manifests/$(basename "$i")"
done
