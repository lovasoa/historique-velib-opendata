#!/usr/bin/env bash

wget -O stations.zip 'https://github.com/lovasoa/historique-velib-opendata/releases/download/latest/stations.zip'
unzip -o stations.zip -d stations
