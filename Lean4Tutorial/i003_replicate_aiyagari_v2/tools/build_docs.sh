#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
NAMES=("$@")
if [ ${#NAMES[@]} -eq 0 ]; then NAMES=(architecture proof_ledger); fi
for NAME in "${NAMES[@]}"; do
  case "$NAME" in architecture|proof_ledger) ;; *) echo "Unknown document: $NAME" >&2; exit 2 ;; esac
  sed '1d' "$ROOT/docs/$NAME.md" > "$TMP/$NAME.md"
  if [[ "$NAME" == "architecture" ]]; then
    TITLE='Aiyagari (1993/1994)'
    SUBTITLE='Theory-only Lean replication architecture and Codex execution specification'
    TOC=(--toc --toc-depth=2)
    EXTRA=()
  else
    TITLE='Aiyagari: Proof Ledger'
    SUBTITLE='M00, M01 and M02A accepted / 50 contracts unformalized'
    TOC=()
    EXTRA=(--include-in-header="$ROOT/docs/ledger_header.tex")
  fi
  pandoc "$TMP/$NAME.md" \
    --from=markdown+tex_math_dollars+tex_math_single_backslash \
    --to=latex --standalone --shift-heading-level-by=-1 --no-highlight \
    ${TOC[@]+"${TOC[@]}"} ${EXTRA[@]+"${EXTRA[@]}"} \
    --metadata title="$TITLE" --metadata subtitle="$SUBTITLE" \
    --metadata date='September 11, 2026 -- Version 1.0' \
    --variable documentclass=article --variable fontsize=11pt \
    --variable geometry:margin=0.85in --variable fontfamily=lmodern \
    --variable colorlinks=true --variable linkcolor=Accent --variable urlcolor=Accent --variable citecolor=Accent \
    --include-in-header="$ROOT/docs/header.tex" \
    --output="$ROOT/docs/$NAME.tex"
  (cd "$ROOT/docs" && latexmk -pdf -interaction=nonstopmode -halt-on-error "$NAME.tex")
done
