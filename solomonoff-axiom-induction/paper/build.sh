#!/bin/bash
# Build the paper: merge bibliographies, then pdflatex/bibtex/pdflatex/pdflatex.
# Run only as: flock /tmp/claude-0/paper-build-sai.lock ./build.sh
set -e
cd "$(dirname "$0")"
python3 merge_bib.py
pdflatex -interaction=nonstopmode main.tex > build1.log 2>&1 || true
bibtex main > bibtex.log 2>&1 || true
pdflatex -interaction=nonstopmode main.tex > build2.log 2>&1 || true
pdflatex -interaction=nonstopmode main.tex > build3.log 2>&1 || true
echo "LaTeX errors: $(grep -c '^!' build3.log)"
echo "Undefined references: $(grep -c 'Reference.*undefined' build3.log)"
echo "Undefined citations: $(grep -c 'Citation.*undefined' build3.log)"
echo "Multiply defined labels: $(grep -c 'multiply defined' build3.log)"
echo "Overfull hboxes >10pt: $(grep -E 'Overfull \\hbox \(([1-9][0-9]+)' build3.log | wc -l)"
echo "BibTeX warnings: $(grep -c -i 'warning' bibtex.log)"
[ -f main.pdf ] && echo "Pages: $(pdfinfo main.pdf 2>/dev/null | grep Pages | awk '{print $2}')"
