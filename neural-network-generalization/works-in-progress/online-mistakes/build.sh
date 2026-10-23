#!/usr/bin/env bash
set -euo pipefail
collection_dir="$(cd -- "$(dirname -- "$0")" && pwd)"
for paper in upper circuit-converse; do
  "$collection_dir/$paper/build.sh"
done
