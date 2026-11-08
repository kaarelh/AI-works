#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p build
for pass in 1 2 3; do
  pdflatex -halt-on-error -interaction=nonstopmode -output-directory=build source/paper.tex > "build/pass-${pass}.log"
done
cp build/paper.pdf paper.pdf
