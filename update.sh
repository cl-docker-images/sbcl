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
        gitDir="$(mktemp -d)"
        git clone --shallow-since "2 months" "https://github.com/sbcl/sbcl.git" "$gitDir"
        sbclGitSha="$(git -C "$gitDir" rev-parse HEAD)"
        (cd "$gitDir" && ./generate-version.sh)
        sbclGitVersion="$(tail -n 1 "$gitDir/version.lisp-expr" | tail -c +2 | head -c -2)"
        rm -rf "$gitDir"

        unset sbclSourceUrl
        unset sbclSourceSha
    else
        unset gitDir
        unset sbclGitSha
        unset sbclGitVersion
        sbclSourceUrl="https://downloads.sourceforge.net/project/sbcl/sbcl/$version/sbcl-$version-source.tar.bz2"
        sbclSourceSha="$(curl -fsSL "$sbclSourceUrl" | sha256sum | cut -d' ' -f1)"
    fi

    for v in \
        buster/{,slim} \
        stretch/{,slim} \
        alpine3.13/ \
        alpine3.12/ \
        windowsservercore-{ltsc2016,1809}/ \
    ; do
        os="${v%%/*}"
        variant="${v#*/}"
        dir="$version/$v"

        if [ "$version" = "nightly" ] && [[ "$os" == "windowsservercore"* ]]; then
            continue
        fi

        mkdir -p "$dir"

        case "$os" in
            buster|stretch)
                template="apt"
                if [ "$variant" = "slim" ]; then
                    from="debian:$os"
                else
                    from="buildpack-deps:$os"
                fi
                cp docker-entrypoint.sh "$dir/docker-entrypoint.sh"
                ;;
            alpine*)
                template="apk"
                cp docker-entrypoint.sh "$dir/docker-entrypoint.sh"
                from="alpine:${os#alpine}"
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
                -e 's/^(ENV SBCL_VERSION) .*/\1 '"$sbclGitVersion"'/' \
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
