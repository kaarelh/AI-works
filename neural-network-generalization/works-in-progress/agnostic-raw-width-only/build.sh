#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/source"
for pass in 1 2 3; do
  pdflatex -interaction=nonstopmode -halt-on-error paper.tex > "build-${pass}.stdout"
done
cp paper.pdf ../paper.pdf
