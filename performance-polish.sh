#!/bin/sh
set -eu
SHA="${1:?commit sha required}"
ROOT="/home/u878466595/domains/hositee.com/public_html/corts-expert"
APP="$ROOT/assets/app.js"
APP_HASH_BEFORE="$(sha256sum "$APP" | awk '{print $1}')"

# Replace oversized decorative assets with right-sized WordPress derivatives.
# Tracking code and the lead receiver are intentionally not modified here.
curl -fsSL 'https://corts-e.sa/wp-content/uploads/2025/04/CORTS-EXPERTS-01-300x208.png' -o "$ROOT/assets/logo-main.png"
curl -fsSL 'https://corts-e.sa/wp-content/uploads/2026/08/b6ff2753-e387-455e-bdc7-f8ef7eee2876-300x135.jpg' -o "$ROOT/assets/about-wide.jpg"

# Use the device-native Arabic-capable font stack: zero font request, zero font swap.
TMP_CSS="$ROOT/assets/styles.css.perf"
sed \
  -e '/^@font-face{font-family:CortsArabic;/d' \
  -e 's/font-family:CortsArabic,"Segoe UI",Tahoma,Arial,sans-serif/font-family:system-ui,-apple-system,"Segoe UI",Tahoma,Arial,sans-serif/g' \
  "$ROOT/assets/styles.css" > "$TMP_CSS"
mv "$TMP_CSS" "$ROOT/assets/styles.css"
cat >> "$ROOT/assets/styles.css" <<'CSS'
/* Performance/accessibility pass: presentation only. */
.contact-panel .section-label{color:#f2dcb2}
@media(max-width:760px){.header{backdrop-filter:none}.hero:after{filter:none}}
CSS

# Inline the small shared stylesheet to remove the render-blocking CSS request.
inline_css(){
  f="$1"
  tmp="$f.perf"
  sed -e 's#<link rel="preload" href="/assets/fonts/noto-arabic-tight-subset.woff2" as="font" type="font/woff2" crossorigin>##g' \
      -e "s#src=\"/assets/app.js\" defer#src=\"/assets/app.js?v=$SHA\" defer#g" \
      "$f" > "$tmp.pre"
  awk -v cssfile="$ROOT/assets/styles.css" '
    BEGIN {
      while ((getline line < cssfile) > 0) css = css line "\n";
      close(cssfile)
    }
    {
      marker="<link rel=\"stylesheet\" href=\"/assets/styles.css?v=";
      p=index($0,marker);
      if (p) {
        rest=substr($0,p);
        e=index(rest,">");
        if (e>0) print substr($0,1,p-1) "<style>" css "</style>" substr(rest,e+1);
        else print;
      } else print;
    }
  ' "$tmp.pre" > "$tmp"
  rm -f "$tmp.pre"
  mv "$tmp" "$f"
}
find "$ROOT" -maxdepth 2 -type f -name index.html | while IFS= read -r f; do inline_css "$f"; done

# Long-lived cache for static assets. HTML remains revalidated normally.
cat > "$ROOT/.htaccess" <<'HT'
<IfModule mod_expires.c>
  ExpiresActive On
  ExpiresByType image/png "access plus 1 year"
  ExpiresByType image/jpeg "access plus 1 year"
  ExpiresByType image/webp "access plus 1 year"
  ExpiresByType image/svg+xml "access plus 1 year"
  ExpiresByType font/woff2 "access plus 1 year"
  ExpiresByType text/css "access plus 1 year"
  ExpiresByType application/javascript "access plus 1 year"
</IfModule>
<IfModule mod_headers.c>
  <FilesMatch "\.(?:css|js|woff2|png|jpe?g|webp|svg)$">
    Header set Cache-Control "public, max-age=31536000, immutable"
  </FilesMatch>
</IfModule>
HT

# Proof gates: presentation changed, tracking did not.
APP_HASH_AFTER="$(sha256sum "$APP" | awk '{print $1}')"
[ "$APP_HASH_BEFORE" = "$APP_HASH_AFTER" ]
test "$(find "$ROOT" -maxdepth 2 -type f -name index.html | wc -l)" -eq 13
test "$(wc -c < "$ROOT/assets/logo-main.png")" -lt 25000
grep -Fq '.contact-panel .section-label{color:#f2dcb2}' "$ROOT/assets/styles.css"
! grep -R -Fq 'rel="stylesheet" href="/assets/styles.css' "$ROOT" --include='*.html'
! grep -R -Fq 'assets/fonts/noto-arabic-tight-subset.woff2' "$ROOT" --include='*.html'
grep -Fq '<style>' "$ROOT/index.html"
grep -Fq 'GTM-M9ZK36MB' "$ROOT/index.html"
grep -Fq 'lead_form_success' "$APP"
printf 'CORTS_PERF_OK:%s tracking_sha256=%s\n' "$SHA" "$APP_HASH_AFTER"
