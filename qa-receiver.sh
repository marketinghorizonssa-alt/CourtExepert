#!/bin/sh
set -eu
URL='https://script.google.com/macros/s/AKfycbztk2fHhEAJeUFjIgkzL7na06sHWsrJVkWqpRbxt2CduJvNeyrQHSMpz8EzfNE4UbQv/exec'
curl -LfsS -X POST "$URL" \
 --data-urlencode 'source_id=CORTS_WEBSITE_FORM_V1' \
 --data-urlencode 'source=Website Form' \
 --data-urlencode 'submission_id=CORTS-TECH-QA-20260915-1000' \
 --data-urlencode 'full_name=TECH QA DELETE ME' \
 --data-urlencode 'phone=+966555555555' \
 --data-urlencode 'service=TECH QA DELETE ME' \
 --data-urlencode 'page_url=https://cortsexpert.hositee.com/riyadh-lawyer/' \
 --data-urlencode 'privacy_consent=YES' \
 --data-urlencode 'consent_version=v1'
