#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/source"
pdflatex -interaction=nonstopmode -halt-on-error -output-directory=.. paper.tex > ../verification/build-1.log
pdflatex -interaction=nonstopmode -halt-on-error -output-directory=.. paper.tex > ../verification/build-2.log
