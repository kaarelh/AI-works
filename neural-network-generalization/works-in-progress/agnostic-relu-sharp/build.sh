#!/usr/bin/env bash
set -euo pipefail
paper_dir=$(cd -- "$(dirname -- "$0")" && pwd)
build_dir=$(mktemp -d)
trap 'rm -rf "$build_dir"' EXIT
cp "$paper_dir"/source/*.tex "$build_dir"/
for pass in 1 2 3; do
  (cd "$build_dir" && pdflatex -interaction=nonstopmode -halt-on-error paper.tex) > "$paper_dir/verification/build-$pass.stdout"
done
cp "$build_dir/paper.pdf" "$paper_dir/paper.pdf"
cp "$build_dir/paper.log" "$paper_dir/verification/latex.log"
