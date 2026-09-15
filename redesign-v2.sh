#!/bin/sh
set -eu
SHA="${1:?commit sha required}"
BASE="https://raw.githubusercontent.com/marketinghorizonssa-alt/CourtExepert/$SHA"
curl -fsSL "$BASE/redesign-v2.sh.gz" | gzip -dc | sh -s "$SHA"
