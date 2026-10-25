#!/usr/bin/env bash
set -euo pipefail
paper_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
export SOURCE_DATE_EPOCH="${SOURCE_DATE_EPOCH:-1792886400}"
export FORCE_SOURCE_DATE=1
mkdir -p "$paper_dir/.build"
cd "$paper_dir/source"
latexmk -pdf -interaction=nonstopmode -halt-on-error -file-line-error \
  -outdir="$paper_dir/.build" paper.tex
cp "$paper_dir/.build/paper.pdf" "$paper_dir/paper.pdf"
