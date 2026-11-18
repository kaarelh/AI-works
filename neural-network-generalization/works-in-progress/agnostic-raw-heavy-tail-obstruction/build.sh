#!/usr/bin/env bash
set -euo pipefail
paper_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$paper_root/source"
pdflatex -interaction=nonstopmode -halt-on-error -output-directory="$paper_root" paper.tex
pdflatex -interaction=nonstopmode -halt-on-error -output-directory="$paper_root" paper.tex
