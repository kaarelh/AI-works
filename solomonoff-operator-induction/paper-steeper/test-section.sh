#!/bin/bash
# Usage: ./test-section.sh <section-basename> [<appendix-basename>]
# Compiles one section (and optionally its appendix) alone to catch LaTeX errors.
# Undefined references to other sections are expected and ignored.
set -e
cd "$(dirname "$0")"
name=$1; app=$2
dir=build-test/$name; mkdir -p $dir
python3 merge_bib.py > /dev/null
cat > $dir/test.tex <<TEX
\documentclass[11pt]{article}
\input{../../preamble}
\usepackage[round,authoryear]{natbib}
\graphicspath{{../../}}
\begin{document}
\input{../../sections/$name}
$( [ -n "$app" ] && echo "\\appendix\\input{../../sections/$app}" )
\bibliographystyle{plainnat}
\bibliography{../../bib/all}
\end{document}
TEX
cd $dir
pdflatex -interaction=nonstopmode -halt-on-error test.tex > log1.txt 2>&1 || { grep -A5 '^!' log1.txt | head -40; exit 1; }
bibtex test > bib.txt 2>&1 || true
pdflatex -interaction=nonstopmode -halt-on-error test.tex > log2.txt 2>&1 || { grep -A5 '^!' log2.txt | head -40; exit 1; }
pdflatex -interaction=nonstopmode -halt-on-error test.tex > log3.txt 2>&1 || { grep -A5 '^!' log3.txt | head -40; exit 1; }
echo "OK: pages $(pdfinfo test.pdf | grep Pages | awk '{print $2}'); $(grep -c 'Citation.*undefined' log3.txt || true) undefined citations; $(grep -c 'Reference.*undefined' log3.txt || true) undefined refs (cross-section refs expected)"
