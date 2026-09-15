#!/bin/sh
set -eu
SHA="${1:?commit sha required}"
ROOT="/home/u878466595/domains/hositee.com/public_html/corts-expert"
APP="$ROOT/assets/app.js"
APP_HASH_BEFORE="$(sha256sum "$APP" | awk '{print $1}')"

# Right-size presentation assets only. Tracking code and lead routing are out of scope.
curl -fsSL 'https://corts-e.sa/wp-content/uploads/2025/04/CORTS-EXPERTS-01-300x208.png' -o "$ROOT/assets/logo-main.png"
curl -fsSL 'https://corts-e.sa/wp-content/uploads/2026/08/b6ff2753-e387-455e-bdc7-f8ef7eee2876-300x135.jpg' -o "$ROOT/assets/about-wide.jpg"
curl -fsSL 'https://corts-e.sa/wp-content/uploads/2026/08/00aa2fdc-f880-4035-8eb1-f5d3095f063d-768x512.jpg' -o "$ROOT/assets/hero-mobile.jpg"
curl -fsSL 'https://corts-e.sa/wp-content/uploads/2026/08/df2e7714-ea6f-4c42-bc4b-8903e49cca08-257x300.jpg' -o "$ROOT/assets/about-portrait-small.jpg"

# Device-native Arabic-capable font stack: zero font request and zero font swap.
TMP_CSS="$ROOT/assets/styles.css.perf"
sed \
  -e '/^@font-face{font-family:CortsArabic;/d' \
  -e 's/font-family:CortsArabic,"Segoe UI",Tahoma,Arial,sans-serif/font-family:system-ui,-apple-system,"Segoe UI",Tahoma,Arial,sans-serif/g' \
  "$ROOT/assets/styles.css" > "$TMP_CSS"
mv "$TMP_CSS" "$ROOT/assets/styles.css"
cat >> "$ROOT/assets/styles.css" <<'CSS'
/* Performance/accessibility pass: presentation only. */
.contact-panel .section-label{color:#f2dcb2}
.hero:after{display:none!important}
.hero-media{position:absolute;inset:0 auto 0 0;width:58%;height:100%;z-index:0;overflow:hidden;pointer-events:none}
.hero-media img{width:100%;height:100%;object-fit:cover;opacity:.82;display:block}
@media(max-width:760px){
  .header{backdrop-filter:none}
  .hero-media{width:100%}
  .hero-media img{opacity:.32}
  .lead-card{box-shadow:none}
  .about-main{box-shadow:none}
}
CSS

# Add an explicit responsive hero image so the LCP resource is discoverable immediately.
prepare_html(){
  f="$1"
  tmp="$f.prepare"
  sed \
    -e 's#<section class="hero"><div class="c hero-grid">#<section class="hero"><picture class="hero-media" aria-hidden="true"><source media="(max-width:760px)" srcset="/assets/hero-mobile.jpg"><img src="/assets/hero-main.jpg" width="1024" height="683" fetchpriority="high" decoding="async" alt=""></picture><div class="c hero-grid">#g' \
    -e 's#<section class="hero service-hero"><div class="c hero-grid">#<section class="hero service-hero"><picture class="hero-media" aria-hidden="true"><source media="(max-width:760px)" srcset="/assets/hero-mobile.jpg"><img src="/assets/hero-main.jpg" width="1024" height="683" fetchpriority="high" decoding="async" alt=""></picture><div class="c hero-grid">#g' \
    -e 's#<link rel="preload" href="/assets/hero-main.jpg" as="image" fetchpriority="high">#<link rel="preload" href="/assets/hero-mobile.jpg" as="image" media="(max-width:760px)" fetchpriority="high"><link rel="preload" href="/assets/hero-main.jpg" as="image" media="(min-width:761px)" fetchpriority="high">#g' \
    -e 's#<img class="about-main" src="/assets/about-portrait.jpg"#<img class="about-main" src="/assets/about-portrait.jpg" srcset="/assets/about-portrait-small.jpg 257w, /assets/about-portrait.jpg 768w" sizes="(max-width:760px) 78vw, 360px"#g' \
    "$f" > "$tmp"
  mv "$tmp" "$f"
}
find "$ROOT" -maxdepth 2 -type f -name index.html | while IFS= read -r f; do prepare_html "$f"; done

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
test -s "$ROOT/assets/hero-mobile.jpg"
test -s "$ROOT/assets/about-portrait-small.jpg"
grep -Fq '.contact-panel .section-label{color:#f2dcb2}' "$ROOT/assets/styles.css"
grep -Fq 'class="hero-media"' "$ROOT/index.html"
grep -Fq 'fetchpriority="high"' "$ROOT/index.html"
grep -Fq 'hero-mobile.jpg' "$ROOT/index.html"
! grep -R -Fq 'rel="stylesheet" href="/assets/styles.css' "$ROOT" --include='*.html'
! grep -R -Fq 'assets/fonts/noto-arabic-tight-subset.woff2' "$ROOT" --include='*.html'
grep -Fq '<style>' "$ROOT/index.html"
grep -Fq 'GTM-M9ZK36MB' "$ROOT/index.html"
grep -Fq 'lead_form_success' "$APP"
printf 'CORTS_PERF_OK:%s tracking_sha256=%s\n' "$SHA" "$APP_HASH_AFTER"
