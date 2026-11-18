#!/usr/bin/env bash
set -euo pipefail
paper_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
build_log="$(mktemp)"
trap 'rm -f "$build_log"' EXIT
cd "$paper_root/source"
for pass in 1 2; do
  if ! pdflatex -interaction=nonstopmode -halt-on-error -output-directory="$paper_root" paper.tex >"$build_log" 2>&1; then
    cat "$build_log"
    exit 1
  fi
done
if rg -q 'undefined references|Reference .* undefined|Citation .* undefined' "$paper_root/paper.log"; then
  rg 'undefined' "$paper_root/paper.log"
  exit 1
fi
printf 'Built %s\n' "$paper_root/paper.pdf"
