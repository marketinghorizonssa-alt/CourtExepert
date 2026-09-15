#!/bin/sh
set -eu
SHA="${1:?commit sha required}"
ROOT="/home/u878466595/domains/hositee.com/public_html/corts-expert"
ENDPOINT="https://script.google.com/macros/s/AKfycbztk2fHhEAJeUFjIgkzL7na06sHWsrJVkWqpRbxt2CduJvNeyrQHSMpz8EzfNE4UbQv/exec"
cat > "$ROOT/assets/app.js" <<'JS'
(()=>{
const ENDPOINT='https://script.google.com/macros/s/AKfycbztk2fHhEAJeUFjIgkzL7na06sHWsrJVkWqpRbxt2CduJvNeyrQHSMpz8EzfNE4UbQv/exec';
const dl=window.dataLayer=window.dataLayer||[];
const qs=new URLSearchParams(location.search);
const attrs=['gclid','gbraid','wbraid','utm_source','utm_medium','utm_campaign','utm_term','utm_content','campaign_id','adgroup_id','creative_id'];
const ar='٠١٢٣٤٥٦٧٨٩';
const fa='۰۱۲۳۴۵۶۷۸۹';
const toEn=s=>String(s||'').replace(/[٠-٩]/g,d=>String(ar.indexOf(d))).replace(/[۰-۹]/g,d=>String(fa.indexOf(d)));
const normPhone=v=>{let p=toEn(v).replace(/[^\d+]/g,'');if(p.startsWith('00966'))p='+'+p.slice(2);else if(p.startsWith('966'))p='+'+p;else if(/^05\d{8}$/.test(p))p='+966'+p.slice(1);else if(/^5\d{8}$/.test(p))p='+966'+p;return p};
const makeId=()=>`CORTS-WEB-${Date.now()}-${Math.random().toString(36).slice(2,10).toUpperCase()}`;
document.querySelectorAll('form[data-lead-form]').forEach(form=>form.addEventListener('submit',async e=>{
 e.preventDefault();
 const btn=form.querySelector('button[type=submit]'),msg=form.querySelector('.msg'),fd=new FormData(form);
 const phone=normPhone(fd.get('phone'));
 if(!/^\+9665\d{8}$/.test(phone)){msg.className='msg err';msg.textContent='أدخل رقم جوال سعودي صحيح';return}
 if(!fd.get('privacy_consent')){msg.className='msg err';msg.textContent='يلزم الموافقة على سياسة الخصوصية';return}
 const submission_id=makeId();
 const p={source_id:'CORTS_WEBSITE_FORM_V1',source:'Website Form',submission_id,full_name:String(fd.get('name')||'').trim(),phone,service:String(fd.get('service')||'').trim(),message:String(fd.get('message')||'').trim(),page_url:location.href.split('#')[0],referrer:document.referrer||'',privacy_consent:'YES',consent_version:'v1',city:'Riyadh'};
 attrs.forEach(k=>p[k]=qs.get(k)||'');
 btn.disabled=true;const old=btn.textContent;btn.textContent='جاري الإرسال...';
 try{
   const ctl=new AbortController();const t=setTimeout(()=>ctl.abort(),12000);
   const r=await fetch(ENDPOINT,{method:'POST',headers:{'Content-Type':'application/x-www-form-urlencoded;charset=UTF-8'},body:new URLSearchParams(p),signal:ctl.signal});clearTimeout(t);
   const txt=await r.text();
   if(!r.ok)throw new Error('receiver_http_'+r.status);
   let ok=true;try{const j=JSON.parse(txt);if(j&&Object.prototype.hasOwnProperty.call(j,'success'))ok=String(j.success)==='true'}catch{}
   if(!ok)throw new Error('receiver_rejected');
   form.reset();const c=form.querySelector('[name=privacy_consent]');if(c)c.checked=true;
   msg.className='msg ok';msg.textContent='تم استلام طلبك بنجاح.';
   dl.push({event:'lead_form_success',form_name:'CORTS_WEBSITE_FORM_V1',submission_id,service:p.service,landing_path:location.pathname});
 }catch(err){msg.className='msg err';msg.textContent='تعذر تأكيد استلام الطلب الآن. يمكنك التواصل مباشرة عبر واتساب أو الاتصال.'}
 finally{btn.disabled=false;btn.textContent=old}
}));
})();
JS
for f in $(find "$ROOT" -name index.html -type f); do
  sed -i -E 's#src="/assets/app\.js(\?v=[^"]*)?" defer#src="/assets/app.js?v='"$SHA"'" defer#g' "$f"
done
grep -Fq 'CORTS_WEBSITE_FORM_V1' "$ROOT/assets/app.js"
grep -Fq 'lead_form_success' "$ROOT/assets/app.js"
grep -Fq "$ENDPOINT" "$ROOT/assets/app.js"
if grep -Fq "document.querySelectorAll('a[data-event]')" "$ROOT/assets/app.js"; then exit 1; fi
if grep -Fq 'whatsapp_after_form' "$ROOT/assets/app.js"; then exit 1; fi
grep -Fq "/assets/app.js?v=$SHA" "$ROOT/index.html"
printf '%s\n' "$SHA" > "$ROOT/RELEASE"
printf 'CORTS_TRACKING_OK:%s\n' "$SHA"
