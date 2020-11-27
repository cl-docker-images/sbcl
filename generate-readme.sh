#!/usr/bin/env bash
set -Eeuo pipefail

declare -A sharedTags
declare -a simpleTags=()

while read -r line; do
    if [[ "$line" == "Tags: "* ]]; then
        line="${line#Tags: }"
        line="$(echo "$line" | tr -d ,)"
        canonicalTag="${line%% *}"
        simpleTags+=( "$line" )
    elif [[ "$line" == "SharedTags: "* ]]; then
        line="${line#SharedTags: }"
        line="$(echo "$line" | tr -d ,)"
        for sharedTag in $line; do
            if [ -z "${sharedTags[$sharedTag]+set}" ]; then
                sharedTags[$sharedTag]="$canonicalTag"
            else
                sharedTags[$sharedTag]="${sharedTags[$sharedTag]} $canonicalTag"
            fi

        done
    else
        unset canonicalTag
    fi
done

simpleTagSection=""

for line in "${simpleTags[@]}"; do
    simpleTagSection="$simpleTagSection-  "
    for tag in $line; do
        simpleTagSection="$simpleTagSection \`$tag\`"
    done
    simpleTagSection="$simpleTagSection
"
done

sharedTagSection=""
declare -A skip=()

for sharedTag in "${!sharedTags[@]}"; do
    [ -z "${skip[$sharedTag]+set}" ] || continue

    sharedTagSection="$sharedTagSection-   \`$sharedTag\`"

    for sharedTag2 in "${!sharedTags[@]}"; do
        ! [ "$sharedTag" = "$sharedTag2" ] || continue
        if [ "${sharedTags[$sharedTag]}" = "${sharedTags[$sharedTag2]}" ]; then
            skip[$sharedTag2]="yes"
            sharedTagSection="$sharedTagSection, \`$sharedTag2\`"
        fi
    done
    sharedTagSection="$sharedTagSection
"

    for tag in ${sharedTags[$sharedTag]}; do
        sharedTagSection="$sharedTagSection    -   \`$tag\`
"
    done
done

awk -v r="$simpleTagSection" '{gsub(/INSERT-SIMPLE-TAGS/,r)}1' hub-description-template.md | awk -v r="$sharedTagSection" '{gsub(/INSERT-SHARED-TAGS/,r)}1' | sed -e "s,%%IMAGE%%,$1,g"
