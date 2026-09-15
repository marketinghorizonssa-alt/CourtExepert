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

Corts Expert is a Riyadh legal-services website for campaign landing pages.

Canonical site: $DOMAIN/
Market: Riyadh, Saudi Arabia
Language: Arabic
Contact phone: +966556044425

Primary service pages:
- $DOMAIN/riyadh-lawyer/
- $DOMAIN/legal-consultation/
- $DOMAIN/labor-law/
- $DOMAIN/debt-collection-execution/
- $DOMAIN/trademark-intellectual-property/
- $DOMAIN/family-inheritance/
- $DOMAIN/inheritance-estates/
- $DOMAIN/company-law/
- $DOMAIN/business-commercial-law/
- $DOMAIN/real-estate-law/
- $DOMAIN/criminal-specialized/

Sitemap: $DOMAIN/sitemap.xml
Privacy: $DOMAIN/privacy/
EOF
[ "$(grep -o '<url>' "$ROOT/sitemap.xml" | wc -l)" -eq 13 ]
grep -Fq 'User-agent: Google-InspectionTool' "$ROOT/robots.txt"
grep -Fq 'Sitemap: https://cortsexpert.hositee.com/sitemap.xml' "$ROOT/robots.txt"
test -s "$ROOT/llms.txt"
printf 'CORTS_SEO_OK:%s\n' "$SHA"
