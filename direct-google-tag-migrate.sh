#!/bin/sh
set -eu
SHA="${1:?commit sha required}"
ROOT="/home/u878466595/domains/hositee.com/public_html/corts-expert"
APP="$ROOT/assets/app.js"
EXPECTED_APP_HASH="9f01dad0e58e28e18ad34ba7b1bb729c94274545e5d2c8f34747c898f301cb52"
DEST="AW-18435697489"
FORM_LABEL="T1E7CNieyvAcENHW6dZE"
WA_LABEL="dgnOCNueyvAcENHW6dZE"
CALL_LABEL="ppiUCN6eyvAcENHW6dZE"
BACKUP="/home/u878466595/corts-direct-tag-backups/$SHA"
SUCCESS=0

APP_HASH_BEFORE="$(sha256sum "$APP" | sed 's/ .*//')"
[ "$APP_HASH_BEFORE" = "$EXPECTED_APP_HASH" ]

# Back up only the files this migration can change, outside public_html.
rm -rf "$BACKUP"
mkdir -p "$BACKUP/assets"
cp "$APP" "$BACKUP/assets/app.js"
find "$ROOT" -maxdepth 2 -type f -name index.html | while IFS= read -r f; do
  rel="${f#$ROOT/}"
  mkdir -p "$BACKUP/$(dirname "$rel")"
  cp "$f" "$BACKUP/$rel"
done

rollback(){
  [ "$SUCCESS" -eq 1 ] && return 0
  if [ -s "$BACKUP/assets/app.js" ]; then cp "$BACKUP/assets/app.js" "$APP"; fi
  find "$BACKUP" -maxdepth 2 -type f -name index.html | while IFS= read -r f; do
    rel="${f#$BACKUP/}"
    cp "$f" "$ROOT/$rel"
  done
  rm -f "$ROOT/assets/google-ads-direct.js"
}
trap rollback EXIT INT TERM HUP

# Tiny first-party event bridge. Same Google Ads actions/labels as the published GTM container.
cat > "$ROOT/assets/google-ads-direct.js" <<JS
(()=>{
const SEND={lead_form_success:'$DEST/$FORM_LABEL',click_whatsapp:'$DEST/$WA_LABEL',click_call:'$DEST/$CALL_LABEL'};
let lastKey='',lastAt=0;
const fire=ev=>{const sendTo=SEND[ev];if(!sendTo||typeof window.gtag!=='function')return;window.gtag('event','conversion',{send_to:sendTo});};
document.addEventListener('click',e=>{const a=e.target.closest&&e.target.closest('a[data-event]');if(!a)return;const ev=a.dataset.event;if(ev!=='click_whatsapp'&&ev!=='click_call')return;const key=ev+'|'+a.href,now=Date.now();if(key===lastKey&&now-lastAt<1000)return;lastKey=key;lastAt=now;fire(ev);},{capture:true,passive:true});
window.CORTS_GTAG_CONVERSION=ev=>fire(ev);
})();
JS

# Keep the durable receiver and canonical dataLayer event unchanged; add only a direct Ads send after confirmed acknowledgement.
TMP_APP="$APP.direct"
sed "s#dl.push({event:'lead_form_success',form_name:'CORTS_WEBSITE_FORM_V1',submission_id,service:p.service,landing_path:location.pathname});#dl.push({event:'lead_form_success',form_name:'CORTS_WEBSITE_FORM_V1',submission_id,service:p.service,landing_path:location.pathname});if(typeof window.CORTS_GTAG_CONVERSION==='function')window.CORTS_GTAG_CONVERSION('lead_form_success');#" "$APP" > "$TMP_APP"
mv "$TMP_APP" "$APP"

patch_html(){
  f="$1"
  tmp="$f.direct"
  cp "$f" "$tmp"

  # Load the Google tag directly instead of loading the GTM runtime first.
  sed -i "s#j.src='https://www.googletagmanager.com/gtm.js?id='+i#j.src='https://www.googletagmanager.com/gtag/js?id=$DEST'#" "$tmp"
  sed -i "s#</script></head>#</script><script>window.dataLayer=window.dataLayer||[];function gtag(){dataLayer.push(arguments)};gtag('js',new Date());gtag('config','$DEST');</script></head>#" "$tmp"
  sed -i 's#<noscript><iframe src="https://www.googletagmanager.com/ns.html?id=GTM-M9ZK36MB" height="0" width="0" style="display:none;visibility:hidden"></iframe></noscript>##' "$tmp"

  # The local bridge replaces the GTM Custom HTML click listener and conversion tags.
  sed -i "s#<script src=\"/assets/app.js?v=[^\"]*\" defer></script>#<script src=\"/assets/google-ads-direct.js?v=$SHA\" defer></script><script src=\"/assets/app.js?v=$SHA\" defer></script>#" "$tmp"
  mv "$tmp" "$f"
}
find "$ROOT" -maxdepth 2 -type f -name index.html | while IFS= read -r f; do patch_html "$f"; done

# Migration gates: exact destination/labels, one direct Google tag, durable form receiver still intact, GTM runtime gone.
test "$(find "$ROOT" -maxdepth 2 -type f -name index.html | wc -l)" -eq 13
test -s "$ROOT/assets/google-ads-direct.js"
grep -Fq "$DEST/$FORM_LABEL" "$ROOT/assets/google-ads-direct.js"
grep -Fq "$DEST/$WA_LABEL" "$ROOT/assets/google-ads-direct.js"
grep -Fq "$DEST/$CALL_LABEL" "$ROOT/assets/google-ads-direct.js"
grep -Fq 'CORTS_WEBSITE_FORM_V1' "$APP"
grep -Fq 'lead_form_success' "$APP"
grep -Fq 'CORTS_GTAG_CONVERSION' "$APP"
grep -Fq 'script.google.com/macros/s/AKfycbztk2fHhEAJeUFjIgkzL7na06sHWsrJVkWqpRbxt2CduJvNeyrQHSMpz8EzfNE4UbQv/exec' "$APP"
grep -Fq "googletagmanager.com/gtag/js?id=$DEST" "$ROOT/index.html"
grep -Fq "gtag('config','$DEST')" "$ROOT/index.html"
grep -Fq '/assets/google-ads-direct.js' "$ROOT/index.html"
! grep -R -Fq 'googletagmanager.com/gtm.js' "$ROOT" --include='*.html'
! grep -R -Fq 'googletagmanager.com/ns.html?id=GTM-M9ZK36MB' "$ROOT" --include='*.html'
APP_HASH_AFTER="$(sha256sum "$APP" | sed 's/ .*//')"
[ "$APP_HASH_AFTER" != "$APP_HASH_BEFORE" ]
SUCCESS=1
trap - EXIT INT TERM HUP
printf '%s\n' "$SHA" > "$ROOT/DIRECT_TAG_RELEASE"
printf 'CORTS_DIRECT_TAG_READY:%s before=%s after=%s backup=%s\n' "$SHA" "$APP_HASH_BEFORE" "$APP_HASH_AFTER" "$BACKUP"
