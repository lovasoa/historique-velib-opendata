#!/usr/bin/env bash
set -e

if [ -z "$GITHUB_TOKEN" ]
then
  echo "Missing \$GITHUB_TOKEN"
  exit 1
fi

zip -q --junk-path -r stations.zip stations/*csv

GAPI=https://api.github.com/repos/lovasoa/historique-velib-opendata
AUTH="-HAuthorization: token $GITHUB_TOKEN"

LAST_RELEASE_JSON=$(mktemp)

echo "Downloading last release information"
curl -sS "$AUTH" "$GAPI/releases/latest" > "$LAST_RELEASE_JSON"

UPLOAD_URL=$(
    < "$LAST_RELEASE_JSON" \
    jq -r '.upload_url' |
    sed 's/{.*}//'
)

echo "Uploading new version"
NEW_ASSET_ID=$(
  curl -sS --fail "$AUTH" \
    -H "Content-Type: application/zip" \
    "$UPLOAD_URL?name=stations-$(date -u +"%Y-%m-%dT%H%MZ").zip" \
    --data-binary "@stations.zip" | 
    jq -r '.id'
)

echo "Removing old release asset"
curl -sS --fail -XDELETE "$AUTH" \
  "$GAPI/releases/assets/$(
      <"$LAST_RELEASE_JSON" \
      jq -r '.assets|sort_by(.updated_at)|reverse[]|.id' | tail -n 1
  )"

echo "Renaming asset file"
curl -sS --fail -XPATCH "$AUTH" \
  "$GAPI/releases/assets/$NEW_ASSET_ID" \
  --data-binary "{\"name\":\"stations.zip\",\"label\":\"Latest data per station as of $(date)\"}"
