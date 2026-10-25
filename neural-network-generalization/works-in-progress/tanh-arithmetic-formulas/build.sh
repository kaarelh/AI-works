#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p .build
export TEXINPUTS="$(pwd)/source:${TEXINPUTS:-}"
pdflatex -interaction=nonstopmode -halt-on-error -output-directory=.build source/paper.tex >/dev/null
pdflatex -interaction=nonstopmode -halt-on-error -output-directory=.build source/paper.tex >/dev/null
cp .build/paper.pdf paper.pdf
printf 'Built paper.pdf\n'
