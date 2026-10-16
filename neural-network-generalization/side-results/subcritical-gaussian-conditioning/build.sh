#!/usr/bin/env bash
set -euo pipefail
paper_dir="$(cd -- "$(dirname -- "$0")" && pwd)"
mkdir -p "$paper_dir/build"
cd "$paper_dir/source"
pdflatex -interaction=nonstopmode -halt-on-error -jobname=paper -output-directory="$paper_dir/build" subcritical-gaussian-conditioning.tex
pdflatex -interaction=nonstopmode -halt-on-error -jobname=paper -output-directory="$paper_dir/build" subcritical-gaussian-conditioning.tex
cp "$paper_dir/build/paper.pdf" "$paper_dir/paper.pdf"
