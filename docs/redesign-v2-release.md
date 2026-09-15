# Corts Expert Redesign V2 Release

This release upgrades the campaign site visual system while preserving the verified Riyadh landing architecture and tracking contract.

## Design source
- Client identity/content: Corts WordPress (`corts-e.sa`) read-only.
- Layout benchmark: Etizan campaign site hierarchy, not Etizan branding.
- Brand: navy `#1B3461`, gold `#BE9A5F`, white.

## V2 changes
- Uses the large CORTS EXPERTS-01 logo (1260x873 source).
- Local client-owned hero/about imagery copied during deploy from WordPress generated sizes.
- Local Arabic WOFF2 font copied from our Etizan runtime; no external font request.
- Layered hero + above-the-fold lead form.
- Trust strip, visual About section, service cards, dark Why section, Vision/Mission, six-step process, FAQ, Google Maps embed, CTA band and stronger footer.
- Same structure is applied to all service landing pages with unique H1/title/canonical/service scope.
- Home + 11 service pages + Privacy = 13 pages.
- Maps/images below fold are lazy/deferred where appropriate.
- Preserves GTM `GTM-M9ZK36MB`, durable form receiver, `lead_form_success`, and GTM-only Call/WhatsApp click tracking.

## Packaged source verification
- `redesign-v2.sh.gz` SHA256: `fb3339433ff6c60df2ef47fdc517889f7dac27b02a77e6fab0921409422f3458`
- Expanded `redesign-v2.sh` SHA256: `d73044ecb84441224384a9a01109860f879f93e74a0a70d755913c3ddce9bf65`
- Wrapper verifies both checksums before execution.

## Deployment acceptance gates
The expanded script fails unless the required assets/font exist, 13 pages exist, sitemap contains 13 URLs, the large logo and Google Maps are present, local font CSS is present, GTM is present, and the canonical form-success event remains in `app.js`.

## Release lineage
- Prepared V2 commit: `5c263f212f4ab790285b2078e24a9f155b404929`.
- Deployment must use a main-branch descendant that contains `redesign-v2.sh` and `redesign-v2.sh.gz` and passes checksum verification.
