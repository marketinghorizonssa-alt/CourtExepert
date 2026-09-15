#!/bin/sh
set -eu
SHA="${1:?commit sha required}"
ROOT="/home/u878466595/domains/hositee.com/public_html/corts-expert"
CANARY="$ROOT/_gtag-direct-canary"
APP="$ROOT/assets/app.js"
APP_HASH="$(sha256sum "$APP" | sed 's/ .*//')"

rm -rf "$CANARY"
mkdir -p "$CANARY"
cp "$ROOT/index.html" "$CANARY/index.html"

# Keep the canary out of search. It is only for performance comparison.
sed -i 's#<meta name="viewport" content="width=device-width,initial-scale=1">#<meta name="viewport" content="width=device-width,initial-scale=1"><meta name="robots" content="noindex,nofollow">#' "$CANARY/index.html"

# Replace only the network source used by the existing bootstrap: direct gtag.js instead of gtm.js.
sed -i "s#j.src='https://www.googletagmanager.com/gtm.js?id='+i#j.src='https://www.googletagmanager.com/gtag/js?id=AW-18435697489'#" "$CANARY/index.html"

# Add the official direct Google tag queue/config immediately before </head>.
sed -i "s#</script></head>#</script><script>window.dataLayer=window.dataLayer||[];function gtag(){dataLayer.push(arguments)};gtag('js',new Date());gtag('config','AW-18435697489');</script></head>#" "$CANARY/index.html"

# The GTM noscript iframe is irrelevant to the direct-tag canary and must not remain.
sed -i 's#<noscript><iframe src="https://www.googletagmanager.com/ns.html?id=GTM-M9ZK36MB" height="0" width="0" style="display:none;visibility:hidden"></iframe></noscript>##' "$CANARY/index.html"

# Proof gates. Production files and app.js are not changed.
test -s "$CANARY/index.html"
grep -Fq 'noindex,nofollow' "$CANARY/index.html"
grep -Fq 'googletagmanager.com/gtag/js?id=AW-18435697489' "$CANARY/index.html"
grep -Fq "gtag('config','AW-18435697489')" "$CANARY/index.html"
! grep -Fq 'googletagmanager.com/gtm.js' "$CANARY/index.html"
! grep -Fq 'googletagmanager.com/ns.html?id=GTM-M9ZK36MB' "$CANARY/index.html"
[ "$APP_HASH" = "$(sha256sum "$APP" | sed 's/ .*//')" ]
printf 'CORTS_DIRECT_TAG_CANARY_OK:%s app_sha256=%s\n' "$SHA" "$APP_HASH"
