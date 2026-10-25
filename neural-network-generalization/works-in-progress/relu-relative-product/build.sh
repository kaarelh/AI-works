#!/usr/bin/env bash
set -euo pipefail
task_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
mkdir -p "$task_dir/.build"
cd "$task_dir/source"
latexmk -pdf -interaction=nonstopmode -halt-on-error \
  -outdir="$task_dir/.build" paper.tex
cp "$task_dir/.build/paper.pdf" "$task_dir/paper.pdf"
