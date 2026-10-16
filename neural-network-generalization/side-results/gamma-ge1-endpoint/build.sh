#!/usr/bin/env bash
set -euo pipefail
paper_dir="$(cd -- "$(dirname -- "$0")" && pwd)"
mkdir -p "$paper_dir/build"
cd "$paper_dir/source"
pdflatex -interaction=nonstopmode -halt-on-error -jobname=paper -output-directory="$paper_dir/build" gamma-ge1-endpoint.tex
pdflatex -interaction=nonstopmode -halt-on-error -jobname=paper -output-directory="$paper_dir/build" gamma-ge1-endpoint.tex
cp "$paper_dir/build/paper.pdf" "$paper_dir/paper.pdf"
