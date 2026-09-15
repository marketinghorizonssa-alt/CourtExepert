import fs from 'node:fs';
const root = new URL('../', import.meta.url);
const files=['server.js','public/styles.css','public/app.js','docs/landing-map.json','README.md','package.json'];
for (const f of files) {
  if (!fs.existsSync(new URL(f, root))) throw new Error('Missing '+f);
}
const server=fs.readFileSync(new URL('server.js',root),'utf8');
const app=fs.readFileSync(new URL('public/app.js',root),'utf8');
const css=fs.readFileSync(new URL('public/styles.css',root),'utf8');
const combined=server+'\n'+app+'\n'+css;
for(const token of ['GTM-M9ZK36MB','cortsexpert.hositee.com','0556044425','lead_form_success','click_call','click_whatsapp','/sitemap.xml']){
  if(!combined.includes(token)) throw new Error('Missing token '+token);
}
if(/TODO|example\.com/i.test(combined)) throw new Error('Placeholder found');
if(/\.php\b/i.test(fs.readdirSync(new URL('.',root)).join('\n'))) throw new Error('Unexpected PHP file at project root');
console.log('validation: ok');
