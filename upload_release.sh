#!/usr/bin/env bash

if [ -z "$GITHUB_TOKEN" ]
then
  echo "Missing \$GITHUB_TOKEN"
  exit 1
fi

zip --junk-path -r stations.zip stations/*csv

GAPI=https://api.github.com/repos/lovasoa/historique-velib-opendata
AUTH="-HAuthorization: token $GITHUB_TOKEN"

LAST_RELEASE_JSON=$(mktemp)

curl "$AUTH" "$GAPI/releases/latest" > "$LAST_RELEASE_JSON"

PREVIOUS_ASSET=$(
  <"$LAST_RELEASE_JSON" \
  jq -r '.assets[]|select(.name == "stations.zip")|.id'
)

curl -XDELETE "$AUTH" "$GAPI/releases/assets/$PREVIOUS_ASSET"

UPLOAD_URL=$(
    < "$LAST_RELEASE_JSON" \
    jq -r '.upload_url' |
    sed 's/{.*}//'
)

curl "$AUTH" \
  -H "Content-Type: application/zip" \
  "$UPLOAD_URL?name=stations.zip" \
  --data-binary "@stations.zip"
