#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p build
cd source
for pass in 1 2 3; do
  pdflatex -interaction=nonstopmode -halt-on-error -output-directory=../build paper.tex > ../build/pdflatex-$pass.log
done
cp ../build/paper.pdf ../paper.pdf
