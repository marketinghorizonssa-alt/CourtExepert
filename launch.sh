#!/bin/sh
set -eu
SHA="${1:?commit sha required}"
ROOT="/home/u878466595/domains/hositee.com/public_html/corts-expert"
DOMAIN="https://cortsexpert.hositee.com"
BASE="https://raw.githubusercontent.com/marketinghorizonssa-alt/CourtExepert/$SHA/deploy.sh"
curl -fsSL "$BASE" | sh -s "$SHA"

# Create two additional high-relevance landing paths from the validated shared template.
rm -rf "$ROOT/inheritance-estates" "$ROOT/company-law"
cp -R "$ROOT/family-inheritance" "$ROOT/inheritance-estates"
cp -R "$ROOT/business-commercial-law" "$ROOT/company-law"

# Inheritance page: change title, description, canonical and core service terms.
sed -i \
  -e 's/أحوال شخصية وطلاق ونفقة وحضانة ومواريث في الرياض/محامي مواريث وتركات وتقسيم ميراث في الرياض/g' \
  -e 's/خدمات قضايا الأحوال الشخصية والطلاق والنفقة والحضانة والمواريث في الرياض بحسب الوقائع والمرحلة./خدمات قانونية للمواريث والتركات وحصر الورثة وتقسيم الميراث في الرياض بحسب طبيعة التركة والمرحلة./g' \
  -e 's/طلاق وخلع ونفقة/محامي ميراث/g' \
  -e 's/حضانة/تقسيم التركة/g' \
  -e 's/تقسيم التركات/قسمة الميراث/g' \
  -e 's#family-inheritance/#inheritance-estates/#g' \
  "$ROOT/inheritance-estates/index.html"

# Company page: change title, description, canonical and core service terms.
sed -i \
  -e 's/محامي شركات وقضايا تجارية وعقود وتحكيم في الرياض/محامي شركات وتأسيس وتصفية وإفلاس في الرياض/g' \
  -e 's/خدمات قانونية للشركات والقضايا التجارية والعقود والتحكيم والتصفية في الرياض./خدمات قانونية للشركات في الرياض تشمل التأسيس والهيكلة والتصفية والإفلاس وفق طبيعة المنشأة والطلب./g' \
  -e 's/صياغة العقود/هيكلة الشركات/g' \
  -e 's/نزاعات تجارية/تصفية الشركات/g' \
  -e 's/تصفية وإفلاس/إفلاس وإجراءات نظامية/g' \
  -e 's#business-commercial-law/#company-law/#g' \
  "$ROOT/company-law/index.html"

# Add services dropdown and mobile menu to every page.
OLD='<nav class="links"><a href="/">الرئيسية</a><a href="/riyadh-lawyer/">محامي الرياض</a><a href="/legal-consultation/">الاستشارات</a><a href="/business-commercial-law/">الشركات</a><a class="cta" href="#lead">اطلب استشارة</a></nav>'
NEW='<nav class="links"><a href="/">الرئيسية</a><div class="drop"><a class="drop-trigger" href="/riyadh-lawyer/">خدماتنا ▾</a><div class="drop-menu"><a href="/riyadh-lawyer/">محامي الرياض</a><a href="/legal-consultation/">استشارات قانونية</a><a href="/labor-law/">قضايا عمالية</a><a href="/debt-collection-execution/">تحصيل وتنفيذ</a><a href="/trademark-intellectual-property/">ملكية فكرية وعلامات</a><a href="/family-inheritance/">أحوال شخصية</a><a href="/inheritance-estates/">مواريث وتركات</a><a href="/company-law/">شركات وتأسيس</a><a href="/business-commercial-law/">تجاري وعقود وتحكيم</a><a href="/real-estate-law/">عقارات وتوثيق</a><a href="/criminal-specialized/">جنائي ومتخصص</a></div></div><a href="/legal-consultation/">الاستشارات</a><a class="cta" href="#lead">اطلب استشارة</a></nav><details class="mobile-menu"><summary aria-label="فتح القائمة">☰</summary><div class="mobile-panel"><a href="/">الرئيسية</a><a href="/riyadh-lawyer/">محامي الرياض</a><a href="/legal-consultation/">استشارات قانونية</a><a href="/labor-law/">قضايا عمالية</a><a href="/debt-collection-execution/">تحصيل وتنفيذ</a><a href="/trademark-intellectual-property/">ملكية فكرية وعلامات</a><a href="/family-inheritance/">أحوال شخصية</a><a href="/inheritance-estates/">مواريث وتركات</a><a href="/company-law/">شركات وتأسيس</a><a href="/business-commercial-law/">تجاري وعقود وتحكيم</a><a href="/real-estate-law/">عقارات وتوثيق</a><a href="/criminal-specialized/">جنائي ومتخصص</a></div></details>'
for f in $(find "$ROOT" -name index.html -type f); do
  sed -i "s@$OLD@$NEW@g" "$f"
done
cat >> "$ROOT/assets/styles.css" <<'CSS'
.drop{position:relative}.drop-trigger{display:block}.drop-menu{display:none;position:absolute;top:100%;right:0;width:540px;background:#fff;border:1px solid #eee;border-radius:14px;padding:12px;box-shadow:0 18px 50px #0b1c3826;grid-template-columns:1fr 1fr;gap:2px;z-index:60}.drop:hover .drop-menu,.drop:focus-within .drop-menu{display:grid}.drop-menu a{padding:9px 11px;border-radius:8px;color:var(--n)}.drop-menu a:hover{background:var(--bg);color:var(--g)}.mobile-menu{display:none;position:relative}.mobile-menu summary{list-style:none;cursor:pointer;font-size:28px;color:var(--n);line-height:1}.mobile-menu summary::-webkit-details-marker{display:none}.mobile-panel{position:absolute;top:45px;left:0;width:min(310px,calc(100vw - 28px));max-height:70vh;overflow:auto;background:#fff;border:1px solid #eee;border-radius:14px;padding:10px;box-shadow:0 18px 50px #0b1c3826}.mobile-panel a{display:block;text-decoration:none;padding:9px 10px;border-bottom:1px solid #f0eee9;color:var(--n);font-weight:700}@media(max-width:960px){.mobile-menu{display:block}}
CSS

cat > "$ROOT/sitemap.xml" <<EOF
<?xml version="1.0" encoding="UTF-8"?><urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"><url><loc>$DOMAIN/</loc></url><url><loc>$DOMAIN/riyadh-lawyer/</loc></url><url><loc>$DOMAIN/legal-consultation/</loc></url><url><loc>$DOMAIN/labor-law/</loc></url><url><loc>$DOMAIN/debt-collection-execution/</loc></url><url><loc>$DOMAIN/trademark-intellectual-property/</loc></url><url><loc>$DOMAIN/family-inheritance/</loc></url><url><loc>$DOMAIN/inheritance-estates/</loc></url><url><loc>$DOMAIN/company-law/</loc></url><url><loc>$DOMAIN/business-commercial-law/</loc></url><url><loc>$DOMAIN/real-estate-law/</loc></url><url><loc>$DOMAIN/criminal-specialized/</loc></url><url><loc>$DOMAIN/privacy/</loc></url></urlset>
EOF

# Read-back validation.
test -s "$ROOT/index.html"
test -s "$ROOT/inheritance-estates/index.html"
test -s "$ROOT/company-law/index.html"
test -s "$ROOT/assets/logo.png"
test -s "$ROOT/assets/hero.jpg"
grep -Fq 'GTM-M9ZK36MB' "$ROOT/index.html"
grep -Fq 'class="mobile-menu"' "$ROOT/index.html"
grep -Fq "$DOMAIN/inheritance-estates/" "$ROOT/sitemap.xml"
grep -Fq "$DOMAIN/company-law/" "$ROOT/sitemap.xml"
printf '%s\n' "$SHA" > "$ROOT/RELEASE"
printf 'CORTS_LAUNCH_OK:%s\n' "$SHA"
