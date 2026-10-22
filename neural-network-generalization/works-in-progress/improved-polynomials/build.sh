#!/usr/bin/env bash
set -euo pipefail
collection_dir="$(cd -- "$(dirname -- "$0")" && pwd)"
for paper in original-support-all-scales neuron-averaging shallow original-support; do
  "$collection_dir/$paper/build.sh"
done
