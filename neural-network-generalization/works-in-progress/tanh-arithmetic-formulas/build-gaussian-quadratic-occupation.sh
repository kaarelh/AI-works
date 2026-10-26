#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p .build/gaussian-quadratic-occupation
pdflatex -interaction=nonstopmode -halt-on-error -output-directory=.build/gaussian-quadratic-occupation source/gaussian-quadratic-occupation.tex >/dev/null
pdflatex -interaction=nonstopmode -halt-on-error -output-directory=.build/gaussian-quadratic-occupation source/gaussian-quadratic-occupation.tex >/dev/null
cp .build/gaussian-quadratic-occupation/gaussian-quadratic-occupation.pdf gaussian-quadratic-occupation.pdf
printf 'Built gaussian-quadratic-occupation.pdf\n'
