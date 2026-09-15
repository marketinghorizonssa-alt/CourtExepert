#!/bin/sh
set -eu
SHA="${1:?commit sha required}"
ROOT="/home/u878466595/domains/hositee.com/public_html/corts-expert"
BASE="https://raw.githubusercontent.com/marketinghorizonssa-alt/CourtExepert/$SHA/launch.sh"
curl -fsSL "$BASE" | sh -s "$SHA"
cat >> "$ROOT/assets/styles.css" <<'CSS'
input[type="hidden"]{display:none!important}.mobile-menu:not([open]) .mobile-panel{display:none!important}.btn{min-height:48px;line-height:1.4}.copy h1{overflow-wrap:anywhere}@media(max-width:620px){.form h2{font-size:28px;line-height:1.35}.mobile-panel{z-index:80}}
CSS
grep -Fq 'input[type="hidden"]{display:none!important}' "$ROOT/assets/styles.css"
grep -Fq 'mobile-menu:not([open])' "$ROOT/assets/styles.css"
printf '%s\n' "$SHA" > "$ROOT/RELEASE"
printf 'CORTS_POLISH_OK:%s\n' "$SHA"
