#!/bin/sh
set -eu
MIGRATION_SHA="${1:?migration commit sha required}"
ROOT="/home/u878466595/domains/hositee.com/public_html/corts-expert"
BACKUP="/home/u878466595/corts-direct-tag-backups/$MIGRATION_SHA"
EXPECTED_OLD_APP_HASH="9f01dad0e58e28e18ad34ba7b1bb729c94274545e5d2c8f34747c898f301cb52"

test -d "$BACKUP"
test -s "$BACKUP/index.html"
test -s "$BACKUP/assets/app.js"

cp "$BACKUP/assets/app.js" "$ROOT/assets/app.js"
find "$BACKUP" -maxdepth 2 -type f -name index.html | while IFS= read -r f; do
  rel="${f#$BACKUP/}"
  mkdir -p "$ROOT/$(dirname "$rel")"
  cp "$f" "$ROOT/$rel"
done
rm -f "$ROOT/assets/google-ads-direct.js" "$ROOT/DIRECT_TAG_RELEASE"

APP_HASH="$(sha256sum "$ROOT/assets/app.js" | sed 's/ .*//')"
[ "$APP_HASH" = "$EXPECTED_OLD_APP_HASH" ]
test "$(find "$ROOT" -maxdepth 2 -type f -name index.html | wc -l)" -eq 13
grep -Fq 'GTM-M9ZK36MB' "$ROOT/index.html"
grep -Fq 'googletagmanager.com/gtm.js' "$ROOT/index.html"
grep -Fq 'lead_form_success' "$ROOT/assets/app.js"
! grep -Fq 'CORTS_GTAG_CONVERSION' "$ROOT/assets/app.js"
printf 'CORTS_DIRECT_TAG_ROLLBACK_OK:%s app_sha256=%s\n' "$MIGRATION_SHA" "$APP_HASH"
