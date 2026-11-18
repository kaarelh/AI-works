#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/source"
pdflatex -interaction=nonstopmode -halt-on-error paper.tex
pdflatex -interaction=nonstopmode -halt-on-error paper.tex
cp paper.pdf ../paper.pdf
