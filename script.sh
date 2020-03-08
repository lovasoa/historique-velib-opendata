#!/usr/bin/env bash

set -e

bash -x ./download_historic_data.sh

python3 fetch_data.py

bash -x ./upload_release.sh
