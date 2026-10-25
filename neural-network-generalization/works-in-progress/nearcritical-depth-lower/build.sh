#!/usr/bin/env bash
set -euo pipefail
paper_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
mkdir -p "$paper_dir/build"
latexmk -pdf -interaction=nonstopmode -halt-on-error -outdir="$paper_dir/build" "$paper_dir/source/paper.tex"
cp "$paper_dir/build/paper.pdf" "$paper_dir/paper.pdf"
