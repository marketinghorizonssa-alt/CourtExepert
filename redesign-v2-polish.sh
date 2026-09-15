#!/bin/sh
set -eu
SHA="${1:?commit sha required}"
ROOT="/home/u878466595/domains/hositee.com/public_html/corts-expert"
cat >> "$ROOT/assets/styles.css" <<'CSS'
/* V2 identity + accessibility polish */
:root{--goldText:#866437;--goldDark:#6b4b26}
.header-row{height:96px}
.brand img{width:205px;height:84px;object-fit:contain}
.section-label,.service-num,.service-card a{color:var(--goldText)}
.dark .section-label{color:#d6b77f}
.trust-icon{color:var(--goldText)}
.submit{background:linear-gradient(135deg,var(--goldText),var(--goldDark))}
.cta-band{background:linear-gradient(110deg,var(--goldText),var(--goldDark))}
.focus-ring:focus-visible,a:focus-visible,button:focus-visible,input:focus-visible,select:focus-visible,textarea:focus-visible,summary:focus-visible{outline-color:var(--goldText)}
@media(max-width:760px){.header-row{height:82px}.brand img{width:168px;height:70px}}
CSS

grep -Fq -- '--goldText:#866437' "$ROOT/assets/styles.css"
grep -Fq 'width:205px' "$ROOT/assets/styles.css"
printf 'CORTS_V2_POLISH_OK:%s\n' "$SHA"
