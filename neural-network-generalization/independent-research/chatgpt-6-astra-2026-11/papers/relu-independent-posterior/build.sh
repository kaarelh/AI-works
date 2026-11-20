#!/usr/bin/env bash
set -euo pipefail
paper_dir=$(cd -- "$(dirname -- "$0")" && pwd)
build_dir=$(mktemp -d)
trap 'rm -rf "$build_dir"' EXIT
mkdir -p "$paper_dir/verification"
cp -R "$paper_dir/source/." "$build_dir/"
tectonic_bin=${TECTONIC:-}
if [[ -z "$tectonic_bin" ]] && command -v tectonic >/dev/null 2>&1; then
  tectonic_bin=$(command -v tectonic)
fi
if [[ -n "$tectonic_bin" ]]; then
  flags=(--untrusted --keep-logs)
  if [[ ${TECTONIC_OFFLINE:-0} == 1 ]]; then flags+=(--only-cached); fi
  (cd "$build_dir" && "$tectonic_bin" "${flags[@]}" paper.tex) > "$paper_dir/verification/build.stdout" 2>&1
elif command -v pdflatex >/dev/null 2>&1; then
  for pass in 1 2 3; do
    (cd "$build_dir" && pdflatex -interaction=nonstopmode -halt-on-error paper.tex) > "$paper_dir/verification/build-$pass.stdout" 2>&1
  done
else
  echo 'Install Tectonic or pdflatex, or set TECTONIC to an executable path.' >&2
  exit 1
fi
cp "$build_dir/paper.pdf" "$paper_dir/paper.pdf"
cp "$build_dir/paper.log" "$paper_dir/verification/latex.log"
