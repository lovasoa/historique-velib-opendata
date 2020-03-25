#!/usr/bin/env bash

set -e

base="https://api.github.com/repos/lovasoa/historique-velib-opendata/releases/latest"

AUTH=$([ $GITHUB_TOKEN ] && echo "-HAuthorization: token $GITHUB_TOKEN")

urls=$(
    curl $AUTH --fail --retry 8 --retry-delay 0 "$base" |
    jq -r '.assets|sort_by(.updated_at)|reverse[]|.browser_download_url'
)

outfile=stations.zip
for url in $urls; do
    curl $AUTH --fail --retry 8 --retry-delay 0 --output "$outfile" "$url" &&
    unzip -o $outfile &&
    break || continue
done

rm $outfile
