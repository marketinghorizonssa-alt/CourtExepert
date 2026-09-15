#!/bin/sh
set -eu
SHA="${1:?commit sha required}"
ROOT="/home/u878466595/domains/hositee.com/public_html/corts-expert"
DOMAIN="https://cortsexpert.hositee.com"
BASE="https://raw.githubusercontent.com/marketinghorizonssa-alt/CourtExepert/$SHA/deploy.sh"
curl -fsSL "$BASE" | sh -s "$SHA"

# Split inheritance/estates from family-law intent. Always recreate cleanly.
rm -rf "$ROOT/inheritance-estates"
cp -R "$ROOT/family-inheritance" "$ROOT/inheritance-estates"
sed -i \
  -e 's/أحوال شخصية وطلاق ونفقة وحضانة ومواريث في الرياض/محامي مواريث وتركات وتقسيم ميراث في الرياض/g' \
  -e 's/خدمات قضايا الأحوال الشخصية والطلاق والنفقة والحضانة والمواريث في الرياض بحسب الوقائع والمرحلة./خدمات قانونية للمواريث والتركات وحصر الورثة وتقسيم الميراث في الرياض بحسب طبيعة التركة والمرحلة./g' \
  -e 's/طلاق وخلع ونفقة/محامي ميراث/g' \
  -e 's/حضانة/تقسيم التركة/g' \
  -e 's/حصر ورثة/حصر الورثة/g' \
  -e 's/تقسيم التركات/قسمة الميراث/g' \
  -e 's#family-inheritance/#inheritance-estates/#g' \
  "$ROOT/inheritance-estates/index.html"
sed -i \
  -e 's/أحوال شخصية وطلاق ونفقة وحضانة ومواريث في الرياض/محامي أحوال شخصية وطلاق ونفقة وحضانة في الرياض/g' \
  -e 's/خدمات قضايا الأحوال الشخصية والطلاق والنفقة والحضانة والمواريث في الرياض بحسب الوقائع والمرحلة./خدمات قضايا الأحوال الشخصية والطلاق والنفقة والحضانة في الرياض بحسب الوقائع والمرحلة./g' \
  -e 's/حصر ورثة/استشارات أسرية/g' \
  -e 's/تقسيم التركات/إجراءات الأحوال الشخصية/g' \
  "$ROOT/family-inheritance/index.html"

# Split company formation/liquidation from commercial disputes/contracts/arbitration.
rm -rf "$ROOT/company-law"
cp -R "$ROOT/business-commercial-law" "$ROOT/company-law"
sed -i \
  -e 's/محامي شركات وقضايا تجارية وعقود وتحكيم في الرياض/محامي شركات وتأسيس وتصفية وإفلاس في الرياض/g' \
  -e 's/خدمات قانونية للشركات والقضايا التجارية والعقود والتحكيم والتصفية في الرياض./خدمات قانونية للشركات في الرياض تشمل التأسيس والهيكلة والتصفية والإفلاس وفق طبيعة المنشأة والطلب./g' \
  -e 's/صياغة العقود/هيكلة الشركات/g' \
  -e 's/نزاعات تجارية/تصفية الشركات/g' \
  -e 's/تصفية وإفلاس/إفلاس وإجراءات نظامية/g' \
  -e 's#business-commercial-law/#company-law/#g' \
  "$ROOT/company-law/index.html"
sed -i \
  -e 's/محامي شركات وقضايا تجارية وعقود وتحكيم في الرياض/محامي قضايا تجارية وعقود وتحكيم في الرياض/g' \
  -e 's/خدمات قانونية للشركات والقضايا التجارية والعقود والتحكيم والتصفية في الرياض./خدمات قانونية للقضايا التجارية والعقود والتحكيم في الرياض بحسب نوع النزاع أو العقد والمرحلة الحالية./g' \
  -e 's/تأسيس الشركات/قضايا تجارية/g' \
  -e 's/تصفية وإفلاس/تحكيم تجاري/g' \
  "$ROOT/business-commercial-law/index.html"

find "$ROOT" -name index.html -type f -exec sed -i 's#/business-commercial-law/">الشركات#/company-law/">الشركات#g' {} +

cat > "$ROOT/sitemap.xml" <<EOF
<?xml version="1.0" encoding="UTF-8"?><urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"><url><loc>$DOMAIN/</loc></url><url><loc>$DOMAIN/riyadh-lawyer/</loc></url><url><loc>$DOMAIN/legal-consultation/</loc></url><url><loc>$DOMAIN/labor-law/</loc></url><url><loc>$DOMAIN/debt-collection-execution/</loc></url><url><loc>$DOMAIN/trademark-intellectual-property/</loc></url><url><loc>$DOMAIN/family-inheritance/</loc></url><url><loc>$DOMAIN/inheritance-estates/</loc></url><url><loc>$DOMAIN/company-law/</loc></url><url><loc>$DOMAIN/business-commercial-law/</loc></url><url><loc>$DOMAIN/real-estate-law/</loc></url><url><loc>$DOMAIN/criminal-specialized/</loc></url><url><loc>$DOMAIN/privacy/</loc></url></urlset>
EOF

test -s "$ROOT/inheritance-estates/index.html"
test -s "$ROOT/company-law/index.html"
grep -Fq 'محامي مواريث وتركات وتقسيم ميراث في الرياض' "$ROOT/inheritance-estates/index.html"
grep -Fq 'محامي شركات وتأسيس وتصفية وإفلاس في الرياض' "$ROOT/company-law/index.html"
grep -Fq "$DOMAIN/inheritance-estates/" "$ROOT/sitemap.xml"
grep -Fq "$DOMAIN/company-law/" "$ROOT/sitemap.xml"
printf '%s\n' "$SHA" > "$ROOT/RELEASE"
printf 'CORTS_V2_OK:%s\n' "$SHA"
