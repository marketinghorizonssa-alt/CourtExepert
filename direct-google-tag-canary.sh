#!/bin/sh
set -eu
SHA="${1:?commit sha required}"
ROOT="/home/u878466595/domains/hositee.com/public_html/corts-expert"
CANARY="$ROOT/_gtag-direct-canary"
APP="$ROOT/assets/app.js"
APP_HASH="$(sha256sum "$APP" | sed 's/ .*//')"
DEST="AW-18435697489"

rm -rf "$CANARY"
mkdir -p "$CANARY"
cp "$ROOT/index.html" "$CANARY/index.html"

sed -i 's#<meta name="viewport" content="width=device-width,initial-scale=1">#<meta name="viewport" content="width=device-width,initial-scale=1"><meta name="robots" content="noindex,nofollow">#' "$CANARY/index.html"

OLD="<script>(function(w,d,s,l,i){w[l]=w[l]||[];w[l].push({'gtm.start':new Date().getTime(),event:'gtm.js'});var f=d.getElementsByTagName(s)[0],j=d.createElement(s);j.async=true;j.src='https://www.googletagmanager.com/gtm.js?id='+i;f.parentNode.insertBefore(j,f)})(window,document,'script','dataLayer','GTM-M9ZK36MB');</script>"
NEW="<script async src=\"https://www.googletagmanager.com/gtag/js?id=$DEST\"></script><script>window.dataLayer=window.dataLayer||[];function gtag(){dataLayer.push(arguments)};gtag('js',new Date());gtag('config','$DEST');</script>"
TMP="$CANARY/index.html.tmp"
awk -v old="$OLD" -v new="$NEW" '{p=index($0,old);if(p){$0=substr($0,1,p-1) new substr($0,p+length(old))}print}' "$CANARY/index.html" > "$TMP"
mv "$TMP" "$CANARY/index.html"

sed -i 's#<noscript><iframe src="https://www.googletagmanager.com/ns.html?id=GTM-M9ZK36MB" height="0" width="0" style="display:none;visibility:hidden"></iframe></noscript>##' "$CANARY/index.html"

test -s "$CANARY/index.html"
grep -Fq 'noindex,nofollow' "$CANARY/index.html"
grep -Fq "<script async src=\"https://www.googletagmanager.com/gtag/js?id=$DEST\"></script>" "$CANARY/index.html"
grep -Fq "gtag('config','$DEST')" "$CANARY/index.html"
! grep -Fq 'googletagmanager.com/gtm.js' "$CANARY/index.html"
! grep -Fq 'GTM-M9ZK36MB' "$CANARY/index.html"
! grep -Fq "event:'gtm.js'" "$CANARY/index.html"
[ "$APP_HASH" = "$(sha256sum "$APP" | sed 's/ .*//')" ]
printf 'CORTS_DIRECT_TAG_CANARY_OK:%s app_sha256=%s\n' "$SHA" "$APP_HASH"
