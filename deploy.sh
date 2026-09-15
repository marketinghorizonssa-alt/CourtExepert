#!/bin/sh
set -eu
SHA="${1:?commit sha required}"
ROOT="/home/u878466595/domains/hositee.com/public_html/corts-expert"
TMP="/home/u878466595/.corts-deploy-${SHA}"
ZIP="/home/u878466595/.corts-${SHA}.zip"
URL="https://codeload.github.com/marketinghorizonssa-alt/CourtExepert/zip/${SHA}"
PORT=3999
rm -rf "$TMP" "$ZIP"
mkdir -p "$TMP" "$ROOT"
curl -fsSL "$URL" -o "$ZIP"
unzip -q "$ZIP" -d "$TMP"
SRC=$(find "$TMP" -mindepth 1 -maxdepth 1 -type d | head -n 1)
test -f "$SRC/server.js"
test -f "$SRC/public/styles.css"
test -f "$SRC/public/app.js"
rm -rf "$ROOT"/*
mkdir -p "$ROOT/assets"
cp -f "$SRC/public/styles.css" "$ROOT/assets/styles.css"
cp -f "$SRC/public/app.js" "$ROOT/assets/app.js"
cd "$SRC"
PORT=$PORT node server.js > "$TMP/server.log" 2>&1 &
PID=$!
trap 'kill $PID 2>/dev/null || true; rm -rf "$TMP" "$ZIP"' EXIT
n=0
until curl -fsS "http://127.0.0.1:$PORT/healthz" >/dev/null 2>&1; do
  n=$((n+1)); [ "$n" -ge 15 ] && { cat "$TMP/server.log"; exit 1; }; sleep 1
done
for p in / /riyadh-lawyer/ /legal-consultation/ /labor-law/ /debt-collection-execution/ /trademark-intellectual-property/ /family-inheritance/ /business-commercial-law/ /real-estate-law/ /criminal-specialized/ /privacy/; do
  if [ "$p" = "/" ]; then out="$ROOT/index.html"; else dir="$ROOT${p}"; mkdir -p "$dir"; out="${dir}index.html"; fi
  curl -fsS "http://127.0.0.1:$PORT$p" -o "$out"
  test -s "$out"
done
curl -fsS "http://127.0.0.1:$PORT/robots.txt" -o "$ROOT/robots.txt"
curl -fsS "http://127.0.0.1:$PORT/sitemap.xml" -o "$ROOT/sitemap.xml"
printf '%s\n' "$SHA" > "$ROOT/RELEASE"
kill "$PID" 2>/dev/null || true
trap - EXIT
rm -rf "$TMP" "$ZIP"
printf 'CORTS_DEPLOY_OK:%s\n' "$SHA"
