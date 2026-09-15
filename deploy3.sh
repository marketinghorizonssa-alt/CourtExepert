#!/bin/sh
set -eu
SHA="${1:?commit sha required}"
ROOT="/home/u878466595/domains/hositee.com/public_html/corts-expert"
BASE="https://raw.githubusercontent.com/marketinghorizonssa-alt/CourtExepert/$SHA/deploy2.sh"
curl -fsSL "$BASE" | sh -s "$SHA"
OLD='<nav class="links"><a href="/">الرئيسية</a><a href="/riyadh-lawyer/">محامي الرياض</a><a href="/legal-consultation/">الاستشارات</a><a href="/company-law/">الشركات</a><a class="cta" href="#lead">اطلب استشارة</a></nav>'
NEW='<nav class="links"><a href="/">الرئيسية</a><div class="drop"><a class="drop-trigger" href="/riyadh-lawyer/">خدماتنا ▾</a><div class="drop-menu"><a href="/riyadh-lawyer/">محامي الرياض</a><a href="/legal-consultation/">استشارات قانونية</a><a href="/labor-law/">قضايا عمالية</a><a href="/debt-collection-execution/">تحصيل وتنفيذ</a><a href="/trademark-intellectual-property/">ملكية فكرية وعلامات</a><a href="/family-inheritance/">أحوال شخصية</a><a href="/inheritance-estates/">مواريث وتركات</a><a href="/company-law/">شركات وتأسيس</a><a href="/business-commercial-law/">تجاري وعقود وتحكيم</a><a href="/real-estate-law/">عقارات وتوثيق</a><a href="/criminal-specialized/">جنائي ومتخصص</a></div></div><a href="/legal-consultation/">الاستشارات</a><a class="cta" href="#lead">اطلب استشارة</a></nav><details class="mobile-menu"><summary aria-label="فتح القائمة">☰</summary><div class="mobile-panel"><a href="/">الرئيسية</a><a href="/riyadh-lawyer/">محامي الرياض</a><a href="/legal-consultation/">استشارات قانونية</a><a href="/labor-law/">قضايا عمالية</a><a href="/debt-collection-execution/">تحصيل وتنفيذ</a><a href="/family-inheritance/">أحوال شخصية</a><a href="/inheritance-estates/">مواريث وتركات</a><a href="/company-law/">شركات وتأسيس</a><a href="/business-commercial-law/">تجاري وعقود</a><a href="/real-estate-law/">عقارات</a><a href="/criminal-specialized/">جنائي ومتخصص</a></div></details>'
for f in $(find "$ROOT" -name index.html -type f); do sed -i "s@$OLD@$NEW@g" "$f"; done
cat >> "$ROOT/assets/styles.css" <<'CSS'
.drop{position:relative}.drop-trigger{display:block}.drop-menu{display:none;position:absolute;top:100%;right:0;width:520px;background:#fff;border:1px solid #eee;border-radius:14px;padding:12px;box-shadow:0 18px 50px #0b1c3826;grid-template-columns:1fr 1fr;gap:2px;z-index:60}.drop:hover .drop-menu,.drop:focus-within .drop-menu{display:grid}.drop-menu a{padding:9px 11px;border-radius:8px;color:var(--n)}.drop-menu a:hover{background:var(--bg);color:var(--g)}.mobile-menu{display:none;position:relative}.mobile-menu summary{list-style:none;cursor:pointer;font-size:28px;color:var(--n);line-height:1}.mobile-menu summary::-webkit-details-marker{display:none}.mobile-panel{position:absolute;top:45px;left:0;width:min(310px,calc(100vw - 28px));max-height:70vh;overflow:auto;background:#fff;border:1px solid #eee;border-radius:14px;padding:10px;box-shadow:0 18px 50px #0b1c3826}.mobile-panel a{display:block;text-decoration:none;padding:9px 10px;border-bottom:1px solid #f0eee9;color:var(--n);font-weight:700}@media(max-width:960px){.mobile-menu{display:block}}
CSS
for f in $(find "$ROOT" -name index.html -type f); do grep -Fq 'class="mobile-menu"' "$f"; done
grep -Fq 'مواريث وتركات' "$ROOT/index.html"
grep -Fq '.drop-menu' "$ROOT/assets/styles.css"
printf '%s\n' "$SHA" > "$ROOT/RELEASE"
printf 'CORTS_V3_OK:%s\n' "$SHA"
