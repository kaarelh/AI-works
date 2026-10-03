#!/bin/sh
# Run all T6 sanity checks (multiplicity.py takes a few minutes).
set -e
cd "$(dirname "$0")"
for f in scott_duality.py prob_coherence.py counting_sequents.py mcs_completeness.py contexts_local_global.py misc_checks.py multiplicity.py; do
  echo "== $f"; python3 "$f"
done
