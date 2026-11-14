#!/bin/bash
# Referee's checks of equational.md: how the files verification/eq_*.out were produced.
# Run from verification/.  Needs Python 3 with NumPy and gcc.  Nothing outside verification/ and
# the directory given as WORK is written.  The long steps are marked with their run times on 4 cores.
#
# Usage: ./eq_run_all.sh WORK      (WORK: an empty scratch directory for binaries and large tables)
set -e
WORK=${1:?give a scratch directory}
mkdir -p "$WORK"
export PYTHONDONTWRITEBYTECODE=1
gcc -O2 -o "$WORK/eq_unary" ../code/eq_unary.c -lm
gcc -O2 -Wall -o "$WORK/eq_brute" eq_brute.c -lm

# --- seconds to a minute each ---
python3 eq_test_radius.py > eq_test_radius.out            # (a) test radius; about 40 s
python3 eq_theorem3_general.py > eq_theorem3_general.out  # Theorem 3(3) on further targets
python3 eq_check_sets.py > eq_check_sets.out              # (c), (d) particular sets
python3 eq_prior.py > eq_prior.out                        # weights, Corollary 4; about 30 s
python3 eq_square.py > eq_square.out                      # lemma of Proposition 6
python3 eq_identity_count.py > eq_identity_count.out
python3 eq_doubling_patch.py > eq_doubling_patch.out      # open question 2
python3 eq_remarks.py > eq_remarks.out
python3 eq_analysis_check.py > eq_analysis_check.out      # Section 6.2 tables from the saved table
R=../results
(python3 eq_bound_drift.py $R/eq_unary_cap12_L14.txt $R/eq_unary_cap12_L16.txt
 python3 eq_bound_drift.py $R/eq_unary_cap12_L16.txt $R/eq_unary_cap12_L18.txt) > eq_bound_drift.out

# --- (b) brute force against eq_unary ---
cd "$WORK"
V=$OLDPWD
for spec in "8 10" "10 10" "12 10" "12 12"; do            # 2 s, 20 s, 5 min, 22 min
  set -- $spec
  ./eq_brute $1 $2 strict > brute_$1_$2_strict.txt
  ./eq_brute $1 $2 loose > brute_$1_$2_loose.txt
  ./eq_unary $1 $2 > ref_$1_$2.txt
  python3 $V/eq_compare_tables.py brute_$1_$2_strict.txt -- ref_$1_$2.txt
  diff <(grep -v '^[#T]' brute_$1_$2_strict.txt | sort) <(grep -v '^[#T]' brute_$1_$2_loose.txt | sort) > /dev/null && echo "strict = loose at ($1, $2)"
done
# (12, 14) against the SAVED table: three processes, about 35 min CPU each
for r in 0 1 2; do ./eq_brute 12 14 strict 3 $r > brute_12_14_part$r.txt & done; wait
python3 $V/eq_compare_tables.py brute_12_14_part0.txt brute_12_14_part1.txt brute_12_14_part2.txt -- $V/../results/eq_unary_cap12_L14.txt

# --- reruns of the note's own computation (1 min, 5 min, 23 min) and the rechecks ---
./eq_unary 12 14 dump > all14.txt
./eq_unary 12 18 dump > all18.txt
grep -v "^D " all18.txt | cmp - $V/../results/eq_unary_cap12_L18.txt && echo "L18 table reproduced"
python3 $V/eq_recheck_all.py all18.txt 22 ./eq_unary > $V/eq_recheck_all_L18_to_L22.out      # 20 min
python3 $V/eq_fitting_models.py all18.txt > $V/eq_fitting_models.out
python3 $V/eq_slip.py all14.txt all18.txt > $V/eq_slip.out
