#!/usr/bin/env bash

bash ./download_historic_data.sh

python3 fetch_data.py

bash ./upload_release.sh
