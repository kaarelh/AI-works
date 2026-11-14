#!/bin/bash
# Referee, second pass: how the files verification/eq2_*.out were produced.
# Run from verification/.  Needs Python 3 with NumPy and gcc.  WORK is a scratch directory.
#
# Usage: ./eq2_run_all.sh WORK
set -e
WORK=${1:?give a scratch directory}
mkdir -p "$WORK"
export PYTHONDONTWRITEBYTECODE=1
V=$PWD
P=$V/..
gcc -O2 -o "$WORK/eq_unary_new" ../code/eq_unary.c -lm
gcc -O2 -o "$WORK/eq2_unary_strict" eq2_unary_strict.c -lm

python3 eq2_holes.py > eq2_holes.out                 # Propositions 4a, 4b; about 5 minutes
python3 eq2_prior.py > eq2_prior.out                 # closed forms; about 7 minutes (exact powers)
python3 eq2_props.py "$WORK/eq_unary_new" > eq2_props.out
python3 eq2_test_radius.py > eq2_test_radius.out     # about 3 minutes

# regeneration of the saved outputs (the list in eq2_reruns.out)
cd "$P/code"
for f in test_radius theories prior_tail holes_check; do python3 $f.py | cmp - ../results/$f.out && echo "$f.out reproduced"; done
cd "$WORK"
for L in 14 16 18; do                                # 1, 5 and 23 minutes, twice
  ./eq_unary_new 12 $L | cmp - "$P/results/eq_unary_cap12_L$L.txt" && echo "eq_unary 12 $L reproduced"
  ./eq2_unary_strict 12 $L | cmp - "$P/results/eq_unary_cap12_L$L.txt" && echo "strict variant at L = $L identical"
done
./eq_unary_new 12 18 dump > all18.txt
(cd "$P/code" && python3 eq_unary_recheck.py "$WORK/all18.txt" 22) | cmp - "$P/results/eq_unary_recheck_cap12_L18_to_L22.out" && echo "recheck reproduced"
