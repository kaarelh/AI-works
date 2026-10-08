#!/bin/sh
# Runs the unit tests and all experiments; results in results/*.md and results/*.json, logs in results/*.log.
set +e
cd "$(dirname "$0")"
python3 -m pytest -q tests > results/pytest.txt 2>&1 || true
cd experiments
for e in e1_universal e2_pa e3_misspec e4_ville e5_gold e6_equivalent e7_prior; do
  echo "== $e" ; date
  python3 $e.py > ../results/$e.log 2>&1
done
date
