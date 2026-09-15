#!/bin/sh
set -eu
SHA="${1:?commit sha required}"
BASE="https://raw.githubusercontent.com/marketinghorizonssa-alt/CourtExepert/$SHA"
GZ="/tmp/corts-redesign-v2-$$.sh.gz"
OUT="/tmp/corts-redesign-v2-$$.sh"
cleanup(){ rm -f "$GZ" "$OUT"; }
trap cleanup EXIT INT TERM
curl -fsSL "$BASE/redesign-v2.sh.gz" -o "$GZ"
printf '%s  %s\n' 'fb3339433ff6c60df2ef47fdc517889f7dac27b02a77e6fab0921409422f3458' "$GZ" | sha256sum -c - >/dev/null
gzip -dc "$GZ" > "$OUT"
printf '%s  %s\n' 'd73044ecb84441224384a9a01109860f879f93e74a0a70d755913c3ddce9bf65' "$OUT" | sha256sum -c - >/dev/null
chmod 700 "$OUT"
sh "$OUT" "$SHA"
