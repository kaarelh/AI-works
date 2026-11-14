#!/usr/bin/env bash
set -euo pipefail
export SOURCE_DATE_EPOCH=1794614400
export FORCE_SOURCE_DATE=1
cd "$(dirname "$0")"
build_dir=$(mktemp -d)
trap 'rm -rf "$build_dir"' EXIT
cp source/*.tex "$build_dir/"
(cd "$build_dir" && pdflatex -interaction=nonstopmode -halt-on-error paper.tex >/dev/null && pdflatex -interaction=nonstopmode -halt-on-error paper.tex >/dev/null)
cp "$build_dir/paper.pdf" paper.pdf
