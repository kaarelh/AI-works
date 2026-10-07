#!/bin/sh
# Regenerate all results (tables in results/*.md, data in results/*.json, figures results/*.png).
# Usage: sh run_all.sh      (from this directory; total wall time is printed at the end)
# v2 (after the referee's report): adds E0b; E2/E3/E4/E5/E9 updated.  The referee's independent oracle checks,
# re-run against the v2 code, are in experiments/recheck (sh experiments/recheck/run_recheck.sh, ~6 min).
set -e
cd "$(dirname "$0")"
start=$(date +%s)
python3 -m pytest -q tests                                   > results/pytest.txt 2>&1
python3 experiments/e0_crossval.py 14 40 F                   > results/e0_crossval_F.txt 2>&1
python3 experiments/e0_crossval.py 13 40 full                > results/e0_crossval_full.txt 2>&1
cd experiments
python3 e0b_property.py 200 > /dev/null
python3 e1_universal.py  > /dev/null
python3 e2_schemas.py    > /dev/null
python3 e3_mix.py        > /dev/null
python3 e4_stress.py     > /dev/null
python3 e5_curves.py     > /dev/null
python3 e6_kunion.py     > /dev/null
python3 e7_blowup.py     > /dev/null
python3 e8_figures.py    > /dev/null
python3 e9_separation.py > /dev/null
python3 e10_pairtable.py 100 > /dev/null
python3 e9b_nosimplify.py > /dev/null
cd ..
end=$(date +%s)
echo "total wall time: $((end - start)) s" | tee results/run_all_time.txt
