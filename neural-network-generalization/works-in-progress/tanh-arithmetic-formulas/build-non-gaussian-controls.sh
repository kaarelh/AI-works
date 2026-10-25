#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p .build/non-gaussian-controls
pdflatex -interaction=nonstopmode -halt-on-error -output-directory=.build/non-gaussian-controls source/non-gaussian-controls.tex >/dev/null
pdflatex -interaction=nonstopmode -halt-on-error -output-directory=.build/non-gaussian-controls source/non-gaussian-controls.tex >/dev/null
cp .build/non-gaussian-controls/non-gaussian-controls.pdf non-gaussian-controls.pdf
