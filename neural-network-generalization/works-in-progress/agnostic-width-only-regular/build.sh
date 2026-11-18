#!/usr/bin/env bash
set -euo pipefail
paper_dir="$(cd "$(dirname "$0")" && pwd)"
build_dir="$(mktemp -d)"
trap 'rm -rf "$build_dir"' EXIT
cp "$paper_dir"/source/*.tex "$build_dir"/
cd "$build_dir"
for pass in 1 2 3; do
 pdflatex -interaction=nonstopmode -halt-on-error paper.tex > "$paper_dir/verification/build-$pass.stdout"
done
cp paper.pdf "$paper_dir/paper.pdf"
cp paper.log "$paper_dir/verification/paper.log"
