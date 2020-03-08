#!/usr/bin/env bash

set -e

base="https://api.github.com/repos/lovasoa/historique-velib-opendata/releases/latest"
urls=$(curl "$base" | jq -r '.assets|sort_by(.updated_at)|reverse[]|.browser_download_url')
outfile=stations.zip
for url in $urls; do
    wget -nv -O "$outfile" "$url" && \
    unzip -q -o $outfile -d stations && \
    break || continue
done

rm $outfile