#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/source"
for pass in 1 2 3; do pdflatex -interaction=nonstopmode -halt-on-error -output-directory=.. paper.tex > ../verification/build.log; done
if rg 'undefined|Overfull' ../paper.log; then exit 1; fi
