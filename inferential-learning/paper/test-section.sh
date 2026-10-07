#!/bin/bash
# Usage: ./test-section.sh <section-basename> [<appendix-basename>]
# Compiles one section (and optionally its appendix) in isolation to catch LaTeX errors.
# Undefined references to other sections are expected and ignored.
set -e
cd "$(dirname "$0")"
name=$1; app=$2
dir=build-test/$name; mkdir -p $dir
cat > $dir/test.tex <<TEX
\documentclass[11pt]{article}
\input{../../preamble}
\usepackage[round,authoryear]{natbib}
\begin{document}
\input{../../sections/$name}
$( [ -n "$app" ] && echo "\\appendix\\input{../../sections/$app}" )
\bibliographystyle{plainnat}
\bibliography{../../bib/$name}
\end{document}
TEX
cd $dir
pdflatex -interaction=nonstopmode -halt-on-error test.tex > log1.txt 2>&1 || { grep -A5 '^!' log1.txt | head -40; exit 1; }
[ -f ../../bib/$name.bib ] && bibtex test > bib.txt 2>&1 || true
pdflatex -interaction=nonstopmode -halt-on-error test.tex > log2.txt 2>&1 || { grep -A5 '^!' log2.txt | head -40; exit 1; }
echo "OK: $(grep -c 'undefined' log2.txt || true) undefined-reference warnings (cross-section refs are expected)"
