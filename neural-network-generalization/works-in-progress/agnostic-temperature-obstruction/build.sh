#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
build_dir=$(mktemp -d)
trap 'rm -rf "$build_dir"' EXIT
cp source/*.tex "$build_dir/"
(
  cd "$build_dir"
  pdflatex -interaction=nonstopmode -halt-on-error paper.tex > pass1.log
  pdflatex -interaction=nonstopmode -halt-on-error paper.tex > pass2.log
)
cp "$build_dir/paper.pdf" paper.pdf
