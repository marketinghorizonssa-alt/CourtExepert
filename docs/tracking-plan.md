# Corts Expert — Tracking Plan

Production: https://cortsexpert.hositee.com
Google Ads customer: 9313544586
GTM: GTM-M9ZK36MB
Market: Riyadh only

## Website events

| Event | Source | Role |
|---|---|---|
| lead_form_success | Website form after CORTS receiver acknowledgement | Intended Primary after QA |
| click_whatsapp | Approved CTA click listener | Separate CTA conversion |
| click_call | Approved CTA click listener | Separate CTA conversion |
| whatsapp_after_form | Post-submit WhatsApp follow-up | Engagement only; never a second lead |

## Lead receiver

- Source ID: CORTS_WEBSITE_FORM_V1
- Receiver: existing CORTS Apps Script web app configured in Corts Ads & Leads Dashboard.
- Required fields: submission_id, service, full_name, phone, page_url, privacy_consent.
- Attribution: gclid, gbraid, wbraid, utm_source, utm_medium, utm_campaign; extended with utm_term, utm_content, campaign_id, adgroup_id, creative_id.
- Consent version: v1.
- submission_id is generated client-side and used as the dedupe / Google Lead ID key.

## CRM-stage actions already present

- CORTS | Qualified Lead | CRM — conversion action ID 7755665487.
- CORTS | Converted Lead | CRM — conversion action ID 7755665490.
- Google Sheets source range: _GOOGLE_ADS_ECL!A:M.

## QA rules

1. Form success must occur only after receiver acknowledgement.
2. lead_form_success must appear once per accepted submission.
3. WhatsApp and Call each fire once from the single approved click source.
4. Preserve click IDs and UTMs through the dashboard.
5. Run one labeled technical test lead and remove it after verifying the destination row.
6. Keep campaigns paused until final tracking and landing QA passes.
