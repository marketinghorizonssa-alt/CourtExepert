#!/bin/sh
set -eu
SHA="${1:?commit sha required}"
BASE="https://raw.githubusercontent.com/marketinghorizonssa-alt/CourtExepert/$SHA/redesign-v2.parts"
RAW="https://raw.githubusercontent.com/marketinghorizonssa-alt/CourtExepert/$SHA"
OUT="/tmp/corts-redesign-v2-$$.sh"
cleanup(){ rm -f "$OUT"; }
trap cleanup EXIT INT TERM
: > "$OUT"
for p in 00 01 02 03 04 05; do
  curl -fsSL "$BASE/part-$p" >> "$OUT"
done
printf '%s  %s\n' '2bdbc7cd2fa04a29033c8e57a23f2a06dc68b46e3c6e839db5422e3c4cbac512' "$OUT" | sha256sum -c - >/dev/null
sh -n "$OUT"
sh "$OUT" "$SHA"
curl -fsSL "$RAW/redesign-v2-polish.sh" | sh -s "$SHA"
