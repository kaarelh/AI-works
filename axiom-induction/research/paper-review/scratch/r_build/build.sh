#!/bin/bash
# test build in scratch copy (not the paper directory)
cd "$(dirname "$0")"
pdflatex -interaction=nonstopmode main.tex > b1.log 2>&1
bibtex main > bt.log 2>&1
pdflatex -interaction=nonstopmode main.tex > b2.log 2>&1
pdflatex -interaction=nonstopmode main.tex > b3.log 2>&1
echo "errors: $(grep -c '^!' b3.log)"
echo "overfull: $(grep -c 'Overfull \\hbox' b3.log)  (>10pt: $(grep -E 'Overfull \\hbox \(([1-9][0-9]+)' b3.log | wc -l))"
echo "underfull: $(grep -c 'Underfull \\hbox' b3.log)"
echo "pages: $(pdfinfo main.pdf | awk '/Pages/{print $2}')"
grep -o 'contentsline {section}{\\numberline {[0-9A-Z]*}[^}]*}{[0-9]*}' main.toc | sed 's/contentsline {section}{\\numberline //'
