#!/bin/sh
set -eu
ROOT="/home/u878466595/domains/hositee.com/public_html/corts-expert"
PAGES="riyadh-lawyer legal-consultation labor-law debt-collection-execution trademark-intellectual-property family-inheritance inheritance-estates company-law business-commercial-law real-estate-law criminal-specialized"
check_page(){ f="$1"; test -s "$f"; grep -Fq '<h1>' "$f"; grep -Fq 'rel="canonical"' "$f"; grep -Fq 'GTM-M9ZK36MB' "$f"; grep -Fq 'data-lead-form' "$f"; grep -Fq '/assets/logo.png' "$f"; }
check_page "$ROOT/index.html"
count=1
for p in $PAGES; do check_page "$ROOT/$p/index.html"; count=$((count+1)); done
test -s "$ROOT/privacy/index.html"
test -s "$ROOT/assets/styles.css"
test -s "$ROOT/assets/app.js"
test -s "$ROOT/assets/logo.png"
test -s "$ROOT/assets/hero.jpg"
grep -Fq 'lead_form_success' "$ROOT/assets/app.js"
grep -Fq 'formsubmit.co/ajax/info@corts-e.sa' "$ROOT/assets/app.js"
grep -Fq 'click_whatsapp' "$ROOT/assets/app.js"
grep -Fq 'click_call' "$ROOT/assets/app.js"
grep -Fq 'class="drop-menu"' "$ROOT/index.html"
grep -Fq 'class="mobile-menu"' "$ROOT/index.html"
! grep -R -Fq 'نية البحث والإعلان' "$ROOT" --include='*.html'
urls=$(grep -o '<url>' "$ROOT/sitemap.xml" | wc -l | tr -d ' ')
[ "$urls" = "13" ]
printf 'CORTS_QA_OK pages=%s sitemap_urls=%s release=%s\n' "$count" "$urls" "$(cat "$ROOT/RELEASE")"
