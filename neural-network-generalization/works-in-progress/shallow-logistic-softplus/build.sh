#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p .build
for name in logistic softplus; do
  pdflatex -interaction=nonstopmode -halt-on-error -output-directory=.build "source/${name}.tex" >/dev/null
  pdflatex -interaction=nonstopmode -halt-on-error -output-directory=.build "source/${name}.tex" >/dev/null
  cp ".build/${name}.pdf" "${name}.pdf"
done
printf 'Built logistic.pdf and softplus.pdf\n'
