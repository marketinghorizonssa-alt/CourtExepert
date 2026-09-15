# Corts Expert — Tracking Plan

Production: https://cortsexpert.hositee.com
Google Ads customer: 9313544586
Google Ads manager: 8480913009
GTM: GTM-M9ZK36MB
Market: Riyadh only

## Website events and Google Ads actions

| Event | Event source | Google Ads action | Role | Conversion ID | Label |
|---|---|---|---|---:|---|
| lead_form_success | Page JS only, after CORTS receiver acknowledgement | CORTS \| Form Submission \| v1 | PRIMARY | 7752290136 | T1E7CNieyvAcENHW6dZE |
| click_whatsapp | GTM approved click listener only | CORTS \| WhatsApp Click \| v1 | SECONDARY | 7752290139 | dgnOCNueyvAcENHW6dZE |
| click_call | GTM approved click listener only | CORTS \| Call Click \| v1 | SECONDARY | 7752290142 | ppiUCN6eyvAcENHW6dZE |

Page JS must never push click_whatsapp or click_call. This prevents duplicate CTA conversions with the existing GTM click listener.

## Lead receiver

- Source ID: CORTS_WEBSITE_FORM_V1
- Receiver: existing CORTS Apps Script web app configured in Corts Ads & Leads Dashboard.
- Required fields: submission_id, service, full_name, phone, page_url, privacy_consent.
- Attribution: gclid, gbraid, wbraid, utm_source, utm_medium, utm_campaign, utm_term, utm_content, campaign_id, adgroup_id, creative_id.
- Consent version: v1.
- submission_id is generated client-side and used as the dedupe / Google Lead ID key.
- Post-submit WhatsApp follow-up is disabled for launch so it cannot accidentally become a second click_whatsapp conversion.

## CRM-stage actions already present

- CORTS | Qualified Lead | CRM — SECONDARY — conversion action ID 7755665487.
- CORTS | Converted Lead | CRM — SECONDARY — conversion action ID 7755665490.
- Google Sheets source range: _GOOGLE_ADS_ECL!A:M.

## Native Google Lead Form

- Asset ID: 419353510413.
- Setup campaign ID: 24238492210, PAUSED.
- Policy state: REVIEW_IN_PROGRESS at last verified dashboard read.
- Do not depend on the Google-hosted lead form until policy is approved and the system submit conversion materializes.

## QA rules

1. Form success must occur only after receiver acknowledgement.
2. lead_form_success must appear exactly once per accepted submission.
3. WhatsApp and Call each fire once from the single GTM click source.
4. Preserve click IDs and UTMs through the dashboard.
5. Run one labeled technical test lead and remove it after verifying the destination row.
6. Keep campaigns paused until final tracking and landing QA passes.
