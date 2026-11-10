#!/bin/sh
# Referee's independent check of Section 6. Run from this directory. Writes *.out here and
# large intermediate files to $TMP (default: ./tmp, not kept).
set -e
TMP=${TMP:-./tmp}; mkdir -p "$TMP"
python3 independent_check.py 8 > independent_check_8.out
gcc -O2 -fopenmp -o "$TMP/independent_full" independent_full.c
gcc -O3 -fopenmp -o "$TMP/independent_profile" independent_profile.c
"$TMP/independent_full" 11 "$TMP/full11.bin" > independent_full_11.out
"$TMP/independent_profile" "$TMP/full11.bin" "$TMP/prof11.bin"
python3 independent_analysis.py "$TMP/full11.bin" "$TMP/prof11.bin" ../results/pr11.npz ../results/nearest11.npy > independent_analysis_11.out
python3 extra_checks.py "$TMP/full11.bin" "$TMP/prof11.bin" > extra_checks.out
# open-term behaviours on (x, y, a); about 20 minutes on 4 cores
gcc -O2 -fopenmp -o "$TMP/independent_open" independent_open.c
"$TMP/independent_open" 11 > independent_open_11.out
