#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p build
pdflatex -interaction=nonstopmode -halt-on-error -output-directory=build source/paper.tex > build/pass1.log
pdflatex -interaction=nonstopmode -halt-on-error -output-directory=build source/paper.tex > build/pass2.log
cp build/paper.pdf paper.pdf
