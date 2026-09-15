#!/bin/sh
set -eu
SHA="${1:?commit sha required}"
ROOT="/home/u878466595/domains/hositee.com/public_html/corts-expert"
DOMAIN="https://cortsexpert.hositee.com"
cat > "$ROOT/robots.txt" <<EOF
User-agent: *
Disallow:

User-agent: Googlebot
Disallow:

User-agent: Google-InspectionTool
Disallow:

Sitemap: $DOMAIN/sitemap.xml
EOF
cat > "$ROOT/llms.txt" <<EOF
# Corts Expert

Corts Expert is a Riyadh legal-services website for campaign landing pages. The site is primarily in Arabic and serves people and businesses seeking legal services in Riyadh, Saudi Arabia.

## Primary pages

- [Home]($DOMAIN/)
- [Lawyer in Riyadh]($DOMAIN/riyadh-lawyer/)
- [Legal consultation]($DOMAIN/legal-consultation/)
- [Labor law]($DOMAIN/labor-law/)
- [Debt collection and enforcement]($DOMAIN/debt-collection-execution/)
- [Trademarks and intellectual property]($DOMAIN/trademark-intellectual-property/)
- [Family law]($DOMAIN/family-inheritance/)
- [Inheritance and estates]($DOMAIN/inheritance-estates/)
- [Company law and formation]($DOMAIN/company-law/)
- [Business, contracts and arbitration]($DOMAIN/business-commercial-law/)
- [Real-estate law and notarization]($DOMAIN/real-estate-law/)
- [Criminal and specialized legal services]($DOMAIN/criminal-specialized/)

## Site resources

- [XML sitemap]($DOMAIN/sitemap.xml)
- [Privacy policy]($DOMAIN/privacy/)

## Contact

Phone: +966556044425
Market: Riyadh, Saudi Arabia
Language: Arabic
EOF
[ "$(grep -o '<url>' "$ROOT/sitemap.xml" | wc -l)" -eq 13 ]
grep -Fq 'User-agent: Google-InspectionTool' "$ROOT/robots.txt"
grep -Fq 'Sitemap: https://cortsexpert.hositee.com/sitemap.xml' "$ROOT/robots.txt"
test -s "$ROOT/llms.txt"
grep -Fq '[Home](https://cortsexpert.hositee.com/)' "$ROOT/llms.txt"
grep -Fq '[XML sitemap](https://cortsexpert.hositee.com/sitemap.xml)' "$ROOT/llms.txt"
printf 'CORTS_SEO_OK:%s\n' "$SHA"
