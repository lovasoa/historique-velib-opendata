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
curl "$AUTH" "$GAPI/releases/latest" > "$LAST_RELEASE_JSON"

echo "Removing old release asset"
curl --fail -XDELETE "$AUTH" \
  "$GAPI/releases/assets/$(
      <"$LAST_RELEASE_JSON" \
      jq -r '.assets[]|select(.name == "stations-old.zip")|.id'
  )"

echo "Renaming current version to old"
curl --fail -XPATCH "$AUTH" \
  "$GAPI/releases/assets/$(
      <"$LAST_RELEASE_JSON" \
      jq -r '.assets[]|select(.name == "stations.zip")|.id'
  )" \
  --data-binary '{"name":"stations-old.zip","label":"Old version"}'

UPLOAD_URL=$(
    < "$LAST_RELEASE_JSON" \
    jq -r '.upload_url' |
    sed 's/{.*}//'
)

echo "Uploading new version"
curl --fail "$AUTH" \
  -H "Content-Type: application/zip" \
  "$UPLOAD_URL?name=stations.zip" \
  --data-binary "@stations.zip"
