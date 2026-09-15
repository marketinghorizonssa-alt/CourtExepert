(() => {
  const dl = window.dataLayer = window.dataLayer || [];
  const menu = document.querySelector('.menu-btn');
  const links = document.querySelector('.nav-links');
  if (menu && links) menu.addEventListener('click', () => links.classList.toggle('open'));

  const qs = new URLSearchParams(location.search);
  const attrs = ['utm_source','utm_medium','utm_campaign','utm_term','utm_content','gclid','gbraid','wbraid'];

  document.querySelectorAll('a[data-event]').forEach(a => {
    a.addEventListener('click', () => {
      dl.push({event:a.dataset.event, link_url:a.href, landing_path:location.pathname});
    }, {passive:true});
  });

  document.querySelectorAll('form[data-lead-form]').forEach(form => {
    form.addEventListener('submit', async (e) => {
      e.preventDefault();
      const btn = form.querySelector('button[type="submit"]');
      const msg = form.querySelector('.form-msg');
      const fd = new FormData(form);
      const payload = Object.fromEntries(fd.entries());
      attrs.forEach(k => payload[k] = qs.get(k) || '');
      payload.landing_path = location.pathname;
      payload.page_title = document.title;
      payload.referrer = document.referrer || '';
      payload.privacy_consent = fd.get('privacy_consent') ? 'yes' : 'no';
      msg.className = 'form-msg'; msg.textContent = '';
      btn.disabled = true; const old = btn.textContent; btn.textContent = 'جاري الإرسال...';
      try {
        const res = await fetch('/api/lead', {method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify(payload)});
        const data = await res.json().catch(() => ({}));
        if (!res.ok || !data.ok) throw new Error(data.error || 'تعذر الإرسال');
        form.reset();
        const consent = form.querySelector('input[name="privacy_consent"]'); if (consent) consent.checked = true;
        msg.className='form-msg ok'; msg.textContent='تم استلام طلبك بنجاح، وسيتواصل معك الفريق.';
        dl.push({event:'lead_form_success',form_name:'corts_website_lead',service:payload.service||'',landing_path:payload.landing_path});
      } catch (err) {
        msg.className='form-msg err'; msg.textContent=err.message || 'حدث خطأ، حاول مرة أخرى أو تواصل هاتفيًا.';
      } finally { btn.disabled=false; btn.textContent=old; }
    });
  });
})();
