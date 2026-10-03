#!/bin/bash
# Build the full paper: merge bibliographies, then pdflatex/bibtex/pdflatex/pdflatex.
set -e
cd "$(dirname "$0")"
python3 merge_bib.py
pdflatex -interaction=nonstopmode main.tex > build1.log 2>&1 || true
bibtex main > bibtex.log 2>&1 || true
pdflatex -interaction=nonstopmode main.tex > build2.log 2>&1 || true
pdflatex -interaction=nonstopmode main.tex > build3.log 2>&1 || true
grep -c "^!" build3.log | xargs -I{} echo "LaTeX errors: {}"
echo "Undefined references: $(grep -c 'Reference.*undefined' build3.log)"
echo "Undefined citations: $(grep -c 'Citation.*undefined' build3.log)"
echo "Multiply defined labels: $(grep -c 'multiply defined' build3.log)"
[ -f main.pdf ] && echo "Pages: $(pdfinfo main.pdf 2>/dev/null | grep Pages | awk '{print $2}')"
