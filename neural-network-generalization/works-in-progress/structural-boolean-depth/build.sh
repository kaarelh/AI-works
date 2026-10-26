#!/usr/bin/env bash
set -euo pipefail
package_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$package_dir/source"
latexmk -pdf -interaction=nonstopmode -halt-on-error paper.tex
cp paper.pdf "$package_dir/paper.pdf"
