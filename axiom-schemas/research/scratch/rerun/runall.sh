#!/bin/bash
cd "$(dirname "$0")"
for s in u_test_refuters u1_pa_cross u2_threshold u3_dtrc_pa u4_zf_cross u6_forall_nontrans u8_noise u5b_bootstrap; do
  t0=$(date +%s); python3 -u $s.py > $s.out 2> $s.err; echo "$s $(( $(date +%s)-t0 ))s" >> timing.txt
done
t0=$(date +%s); python3 -u u7_mdl.py 200 1000 4000 16000 64000 > u7_mdl.out 2> u7_mdl.err; echo "u7 $(( $(date +%s)-t0 ))s" >> timing.txt
t0=$(date +%s); python3 -u u5_dtrc_zf.py > u5_dtrc_zf.out 2> u5_dtrc_zf.err; echo "u5 $(( $(date +%s)-t0 ))s" >> timing.txt
t0=$(date +%s); python3 -u u0_crossval_mincov.py 20 > u0_crossval_mincov.out 2> u0.err; echo "u0 $(( $(date +%s)-t0 ))s" >> timing.txt
echo DONE > done.flag
