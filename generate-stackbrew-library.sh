#!/usr/bin/env bash
set -Eeuo pipefail

declare -A aliases=(
    [2.3.1]='latest'
)

defaultDebianSuite='bullseye'

self="$(basename "$BASH_SOURCE")"
cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

if [ "${1-unset}" = "rc" ]; then
    versions=( *rc/ )
    versions=( "${versions[@]%/}" )
elif [ "${1-unset}" = "all" ]; then
    versions=( */ )
    versions=( "${versions[@]%/}" )
else
    versions=( */ )
    versions=( "${versions[@]%/}" )
    versions=( "${versions[@]%%*rc}" )
fi

# sort version numbers with highest first
IFS=$'\n'; versions=( $(echo "${versions[*]}" | sort -rV) ); unset IFS

# get the most recent commit which modified any of "$@"
fileCommit() {
    git log -1 --format='format:%H' HEAD -- "$@"
}

# get the most recent commit which modified "$1/Dockerfile" or any file COPY'd from "$1/Dockerfile"
dirCommit() {
    local dir="$1"; shift
    (
        cd "$dir"
        fileCommit \
            Dockerfile \
            $(git show HEAD:./Dockerfile | awk '
                toupper($1) == "COPY" {
                    for (i = 2; i < NF; i++) {
                        print $i
                    }
                }
            ')
    )
}

getArches() {
    local repo="$1"; shift
    local officialImagesUrl='https://github.com/docker-library/official-images/raw/master/library/'

    eval "declare -g -A parentRepoToArches=( $(
        find -name 'Dockerfile' -exec awk '
                toupper($1) == "FROM" && $2 !~ /^('"$repo"'|scratch|.*\/.*)(:|$)/ {
                    print "'"$officialImagesUrl"'" $2
                }
            ' '{}' + \
            | sort -u \
            | xargs bashbrew cat --format '[{{ .RepoName }}:{{ .TagName }}]="{{ join " " .TagEntry.Architectures }}"'
    ) )"
}
# getArches 'sbcl'

declare -g -A parentRepoToArches=(
    [alpine:3.14]="amd64 arm32v6 arm32v7 arm64v8 i386 ppc64le s390x"
    [alpine:3.15]="amd64 arm32v6 arm32v7 arm64v8 i386 ppc64le s390x"
    [buildpack-deps:bullseye]="amd64 arm32v6 arm32v7 arm64v8 i386 ppc64le s390x"
    [buildpack-deps:buster]="amd64 arm32v6 arm32v7 arm64v8 i386 ppc64le s390x"
    [debian:bullseye]="amd64 arm32v6 arm32v7 arm64v8 i386 ppc64le s390x"
    [debian:buster]="amd64 arm32v6 arm32v7 arm64v8 i386 ppc64le s390x"
)

cat <<-EOH
# this file is generated via https://github.com/cl-docker-images/sbcl/blob/$(fileCommit "$self")/$self
Maintainers: Eric Timmons <nasafreak@gmail.com> (@daewok)
GitRepo: https://github.com/cl-docker-images/sbcl.git
EOH

# prints "$2$1$3$1...$N"
join() {
    local sep="$1"; shift
    local out; printf -v out "${sep//%/%%}%s" "$@"
    echo "${out#$sep}"
}

for version in "${versions[@]}"; do

    for v in \
        bullseye/{,slim} \
        buster/{,slim} \
        alpine3.15/ \
        alpine3.14/ \
        windowsservercore-{1809,ltsc2019}/ \
    ; do
        os="${v%%/*}"
        variant="${v#*/}"
        if [ -n "$variant" ]; then
            variantTag="-$variant"
        else
            variantTag=""
        fi

        dir="$version/$v"

        if [[ "$version" == *rc ]]; then
            if [[ "$os" == "windowsservercore"* ]] || [ "$variant" = slim ]; then
                continue
            fi
        fi

        [ -f "$dir/Dockerfile" ] || continue

        commit="$(dirCommit "$dir")"

        versionAliases=(
            $version
            ${aliases[$version]:-}
        )

        variantAliases=( "${versionAliases[@]/%/$variantTag-$os}" )
        variantAliases=( "${variantAliases[@]//latest-/}" )

        case "$os" in
            windows*) variantArches='windows-amd64' ;;
            *)
                variantParent="$(awk 'toupper($1) == "FROM" { print $2 }' "$dir/Dockerfile")"
                parentArches="${parentRepoToArches[$variantParent]:-}"
                variantArches=
                for arch in $parentArches; do
                    if echo "$arch" | grep -E "amd64|arm32v7|arm64v8" > /dev/null; then
                        if [ "$arch" == "arm32v7" ] && [ "$os" == "alpine3.12" ]; then
                            continue
                        fi
                        variantArches+=" $arch"
                    fi
                done
                ;;
        esac

        sharedTags=()

        if [ "$os" = "$defaultDebianSuite" ] || [[ "$os" == 'windowsservercore'* ]]; then
            sharedTags+=( "${versionAliases[@]/%/$variantTag}" )

            if [[ "$os" == "windowsservercore"* ]]; then
                sharedTags+=( "${versionAliases[@]/%/-windowsservercore$variantTag}")
            fi
        fi

        sharedTags=( "${sharedTags[@]//latest-/}" )
        parentRepoToArches["daewok/sbcl:${variantAliases[0]}"]="${variantArches[*]}"

        echo
        echo "Tags: $(join ', ' "${variantAliases[@]}")"
        if [ "${#sharedTags[@]}" -gt 0 ]; then
            echo "SharedTags: $(join ', ' "${sharedTags[@]}")"
        fi
        cat <<-EOE
			Architectures: $(join ', ' $variantArches)
			GitCommit: $commit
			Directory: $dir
		EOE
        [[ "$os" == "windows"* ]] && echo "Constraints: $os"
    done
done
