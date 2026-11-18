#!/usr/bin/env bash
set -euo pipefail
paper_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
paper_build=$(mktemp -d)
trap 'rm -rf "$paper_build"' EXIT
cp "$paper_root"/source/*.tex "$paper_build"/
cd "$paper_build"
pdflatex -interaction=nonstopmode -halt-on-error paper.tex > build.log
pdflatex -interaction=nonstopmode -halt-on-error paper.tex >> build.log
pdflatex -interaction=nonstopmode -halt-on-error paper.tex >> build.log
if rg -q 'undefined references|undefined citations|LaTeX Error|Overfull' paper.log; then
  cat build.log
  exit 1
fi
cp paper.pdf "$paper_root/paper.pdf"
cp paper.log "$paper_root/verification/build.log"
