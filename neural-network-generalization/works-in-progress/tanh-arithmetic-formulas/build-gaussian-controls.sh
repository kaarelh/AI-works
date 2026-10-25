#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p .build/gaussian-controls
export TEXINPUTS="$(pwd)/source:${TEXINPUTS:-}"
pdflatex -interaction=nonstopmode -halt-on-error -output-directory=.build/gaussian-controls source/gaussian-controls.tex >/dev/null
pdflatex -interaction=nonstopmode -halt-on-error -output-directory=.build/gaussian-controls source/gaussian-controls.tex >/dev/null
cp .build/gaussian-controls/gaussian-controls.pdf gaussian-controls.pdf
printf 'Built gaussian-controls.pdf\n'
