#!/bin/sh
set -eu
SHA="${1:?commit sha required}"
ROOT="/home/u878466595/domains/hositee.com/public_html/corts-expert"
APP="$ROOT/assets/app.js"
FONT_DIR="$ROOT/assets/fonts"
FONT="$FONT_DIR/beiruti-local-v1.woff2"
APP_HASH_BEFORE="$(sha256sum "$APP" | awk '{print $1}')"

mkdir -p "$FONT_DIR"

# Restore the exact local Beiruti font used by the V2 design before the zero-font-request performance pass.
if [ -s "$ROOT/assets/fonts/noto-arabic-tight-subset.woff2" ]; then
  cp "$ROOT/assets/fonts/noto-arabic-tight-subset.woff2" "$FONT"
else
  curl -fsSL 'https://corts-e.sa/wp-content/themes/twentytwentyfive/assets/fonts/beiruti/Beiruti-VariableFont_wght.woff2' -o "$FONT"
fi

# Official Corts WordPress site icon sizes. New filenames intentionally bypass aggressive browser favicon caches.
curl -fsSL 'https://corts-e.sa/wp-content/uploads/2026/08/cropped-CORTS-EXPERTS-02-1-32x32.png' -o "$ROOT/assets/favicon-32-20260915.png"
curl -fsSL 'https://corts-e.sa/wp-content/uploads/2026/08/cropped-CORTS-EXPERTS-02-1-192x192.png' -o "$ROOT/assets/favicon-192-20260915.png"
curl -fsSL 'https://corts-e.sa/wp-content/uploads/2026/08/cropped-CORTS-EXPERTS-02-1-180x180.png' -o "$ROOT/assets/apple-touch-20260915.png"

# Local WhatsApp brand icon: fetched only at deploy time, served from this site at runtime.
curl -fsSL 'https://cdn.jsdelivr.net/npm/simple-icons@v13/icons/whatsapp.svg' -o "$ROOT/assets/whatsapp-brand-v1.svg"

test -s "$FONT"
test -s "$ROOT/assets/favicon-32-20260915.png"
test -s "$ROOT/assets/favicon-192-20260915.png"
test -s "$ROOT/assets/apple-touch-20260915.png"
test -s "$ROOT/assets/whatsapp-brand-v1.svg"

# Keep the source stylesheet aligned with the live inline CSS for later releases.
if ! grep -Fq 'CORTS_VISUAL_RESTORE_20260915' "$ROOT/assets/styles.css"; then
cat >> "$ROOT/assets/styles.css" <<'CSS'
/* CORTS_VISUAL_RESTORE_20260915 */
@font-face{font-family:CortsArabic;src:url('/assets/fonts/beiruti-local-v1.woff2') format('woff2');font-display:swap;font-style:normal;font-weight:200 900}
body{font-family:CortsArabic,"Segoe UI",Tahoma,Arial,sans-serif}
.floating .wa img{display:block;width:27px;height:27px;filter:brightness(0) invert(1)}
CSS
fi

patch_html(){
  f="$1"
  tmp="$f.visual"
  cp "$f" "$tmp"

  if ! grep -Fq 'favicon-32-20260915.png' "$tmp"; then
    sed -i 's#<meta name="viewport" content="width=device-width,initial-scale=1">#<meta name="viewport" content="width=device-width,initial-scale=1"><link rel="icon" type="image/png" sizes="32x32" href="/assets/favicon-32-20260915.png"><link rel="icon" type="image/png" sizes="192x192" href="/assets/favicon-192-20260915.png"><link rel="apple-touch-icon" sizes="180x180" href="/assets/apple-touch-20260915.png"><meta name="theme-color" content="rgb(27,52,97)">#' "$tmp"
  fi

  # Replace the placeholder W with the actual WhatsApp mark, preserving the original link and data-event.
  sed -i 's#aria-label="تواصل عبر واتساب">W</a>#aria-label="تواصل عبر واتساب"><img src="/assets/whatsapp-brand-v1.svg" width="27" height="27" alt=""></a>#g' "$tmp"
  sed -i 's#aria-label="واتساب">W</a>#aria-label="واتساب"><img src="/assets/whatsapp-brand-v1.svg" width="27" height="27" alt=""></a>#g' "$tmp"

  # The performance pass inlined CSS, so restore the font in the inline CSS too without adding a blocking stylesheet request.
  if ! grep -Fq 'CORTS_VISUAL_RESTORE_20260915' "$tmp"; then
    sed -i 's#</style>#/* CORTS_VISUAL_RESTORE_20260915 */@font-face{font-family:CortsArabic;src:url("/assets/fonts/beiruti-local-v1.woff2") format("woff2");font-display:swap;font-style:normal;font-weight:200 900}body{font-family:CortsArabic,"Segoe UI",Tahoma,Arial,sans-serif}.floating .wa img{display:block;width:27px;height:27px;filter:brightness(0) invert(1)}</style>#' "$tmp"
  fi

  mv "$tmp" "$f"
}

find "$ROOT" -maxdepth 2 -type f -name index.html | while IFS= read -r f; do patch_html "$f"; done

APP_HASH_AFTER="$(sha256sum "$APP" | awk '{print $1}')"
[ "$APP_HASH_BEFORE" = "$APP_HASH_AFTER" ]
test "$(find "$ROOT" -maxdepth 2 -type f -name index.html | wc -l)" -eq 13
grep -Fq 'favicon-32-20260915.png' "$ROOT/index.html"
grep -Fq 'CORTS_VISUAL_RESTORE_20260915' "$ROOT/index.html"
grep -Fq '/assets/whatsapp-brand-v1.svg' "$ROOT/index.html"
! grep -R -Fq 'aria-label="تواصل عبر واتساب">W</a>' "$ROOT" --include='*.html'
grep -Fq 'GTM-M9ZK36MB' "$ROOT/index.html"
grep -Fq 'lead_form_success' "$APP"
printf '%s\n' "$SHA" > "$ROOT/VISUAL_RELEASE"
printf 'CORTS_VISUAL_OK:%s tracking_sha256=%s\n' "$SHA" "$APP_HASH_AFTER"
