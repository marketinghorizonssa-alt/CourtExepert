# Corts Expert Performance Landing Site

Production target: `https://cortsexpert.hositee.com`
Reference identity/content source: `https://corts-e.sa/`

- Static campaign-first Riyadh site deployed from GitHub-reviewed releases
- 13 routes: Home + 11 service intents + Privacy
- GTM: `GTM-M9ZK36MB`
- Primary lead signal: `lead_form_success` after CORTS receiver acknowledgement
- Secondary CTA signals: `click_whatsapp`, `click_call` from GTM only
- Redesign V2 uses the large client logo, local client imagery, local Arabic font, Google Maps embed, accessibility-first navigation and Etizan-level content hierarchy
- No PHP files are used or modified on the original WordPress site

## Redesign V2

See `docs/redesign-v2-release.md`. The deployment wrapper verifies the packaged V2 source checksums before execution.
