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
if rg -n 'undefined references|undefined citations|LaTeX Error|Overfull' "$build_dir/paper.log"; then
  exit 1
fi
mkdir -p verification
cp "$build_dir/paper.pdf" paper.pdf
cp "$build_dir/pass1.log" verification/build-1.stdout
cp "$build_dir/pass2.log" verification/build-2.stdout
