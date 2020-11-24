#!/usr/bin/env bash
set -Eeuo pipefail

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

versions=( "$@" )

generated_warning() {
    cat <<EOH
#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "update.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#
EOH
}

for version in "${versions[@]}"; do

    if [ "$version" = "nightly" ]; then
        sbclGitSha="$(curl -fsSL https://api.github.com/repos/sbcl/sbcl/commits/master | jq -r .sha)"
        unset sbclSourceUrl
        unset sbclSourceSha
    else
        unset sbclGitSha
        sbclSourceUrl="https://downloads.sourceforge.net/project/sbcl/sbcl/$version/sbcl-$version-source.tar.bz2"
        sbclSourceSha="$(curl -fsSL "$sbclSourceUrl" | sha256sum | cut -d' ' -f1)"
    fi

    for v in \
        buster/{,fancy,build} \
        stretch/{,fancy,build} \
        alpine3.12/{,fancy,build} \
        alpine3.11/{,fancy,build} \
        windowsservercore-{ltsc2016,1809}/ \
    ; do
        os="${v%%/*}"
        variant="${v#*/}"
        dir="$version/$v"

        if [ "$version" = "nightly" ] && [[ "$os" == "windowsservercore"* ]]; then
            continue
        fi

        if [ "$version" = "nightly" ]; then
            nightlySuffix="-nightly"
        else
            nightlySuffix=""
        fi

        mkdir -p "$dir"

        case "$os" in
            buster|stretch)
                template="apt"
                if [ "$variant" = "build" ]; then
                    from="daewok/sbcl:$version-$os"
                    cp "rebuild-sbcl.apt$nightlySuffix" "$dir/rebuild-sbcl"
                else
                    from="debian:$os"
                    cp docker-entrypoint.sh "$dir/docker-entrypoint.sh"
                fi
                ;;
            alpine*)
                template="apk"
                cp docker-entrypoint.sh "$dir/docker-entrypoint.sh"
                if [ "$variant" = "build" ]; then
                    from="daewok/sbcl:$version-$os"
                    cp "rebuild-sbcl.apk$nightlySuffix" "$dir/rebuild-sbcl"
                else
                    from="alpine:${os#alpine}"
                    cp docker-entrypoint.sh "$dir/docker-entrypoint.sh"
                fi
                ;;
            windowsservercore-*)
                template='windowsservercore'
                from="mcr.microsoft.com/windows/servercore:${os#*-}"
                ;;
        esac

        if [ -n "$variant" ]; then
            template="$template-$variant"
        fi

        if [ "$version" = "nightly" ]; then
            template="$template-nightly"
        fi

        template="Dockerfile-${template}.template"

        { generated_warning; cat "$template"; } > "$dir/Dockerfile"

        if [ "$version" = "nightly" ]; then
            sed -ri \
                -e 's,^(FROM) .*,\1 '"$from"',' \
                -e 's/^(ENV SBCL_COMMIT) .*/\1 '"$sbclGitSha"'/' \
                "$dir/Dockerfile"
        else
            sed -ri \
                -e 's/^(ENV SBCL_VERSION) .*/\1 '"$version"'/' \
                -e 's/^(ENV SBCL_SOURCE_SHA256) .*/\1 '"$sbclSourceSha"'/' \
                -e 's,^(FROM) .*,\1 '"$from"',' \
                "$dir/Dockerfile"
        fi
    done
done
