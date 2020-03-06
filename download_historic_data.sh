#!/usr/bin/env bash

set -e

base="https://github.com/lovasoa/historique-velib-opendata/releases/download/latest"
outfile=stations.zip

wget -O $outfile "$base/stations.zip" || wget -O $outfile "$base/stations-old.zip"

unzip -q -o $outfile -d stations

rm $outfile
