#!/usr/bin/env bash
set -euo pipefail
task_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
mkdir -p "$task_dir/.build"
cd "$task_dir/source"
for task_document in paper uniform-target-classes; do
  latexmk -pdf -interaction=nonstopmode -halt-on-error \
    -outdir="$task_dir/.build" "$task_document.tex"
  cp "$task_dir/.build/$task_document.pdf" "$task_dir/$task_document.pdf"
done
