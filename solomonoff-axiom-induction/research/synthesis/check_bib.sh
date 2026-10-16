#!/bin/sh
# Synthesis check (2026-10-16): does research/refs.bib parse with BibTeX (plain style, \nocite{*}) and typeset?
# Usage: sh check_bib.sh <research-dir> <scratch-dir>   (writes the summary to stdout)
R="$1"; S="$2"; mkdir -p "$S" && cp "$R/refs.bib" "$S/" && cd "$S" || exit 1
printf '\\documentclass{article}\\usepackage[T1]{fontenc}\\usepackage{url,amssymb}\\begin{document}\\nocite{*}\\bibliographystyle{plain}\\bibliography{refs}\\end{document}\n' > t.tex
rm -f t.aux t.bbl
pdflatex -interaction=nonstopmode t.tex >/dev/null 2>&1; bibtex t > bt.log 2>&1
pdflatex -interaction=nonstopmode t.tex >/dev/null 2>&1; pdflatex -interaction=nonstopmode t.tex >/dev/null 2>&1
echo "entries in refs.bib: $(grep -c '^@' refs.bib)"
echo "bibitems typeset: $(grep -c '\\bibitem' t.bbl)"
echo "bibtex messages:"; grep -i 'warning\|error' bt.log
echo "latex errors (lines starting with !): $(grep -c '^!' t.log)"
echo "latex warnings: $(grep -c 'Warning' t.log)"
