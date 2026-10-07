#!/bin/sh
# Referee checks for track "experiments".  Run from this directory:  sh run_checks.sh   (about 10 minutes)
set -e
cd "$(dirname "$0")"
export PYTHONDONTWRITEBYTECODE=1
python3 r1_params.py            > r1_params.out 2>&1
python3 r2_e7.py                > r2_e7.out 2>&1
python3 r3_record.py PA         > r3_record_PA.out 2>&1
python3 r3_record.py ZF         > r3_record_ZF.out 2>&1
python3 r3_check.py PA          > r3_check_PA.out 2>&1
python3 r3_check.py ZF          > r3_check_ZF.out 2>&1
python3 r3b_deep.py             > r3b_deep.out 2>&1
python3 r4_fuzz.py PA 3000 2    > r4_fuzz_PA.out 2>&1
python3 r4_fuzz.py ZF 600 5     > r4_fuzz_ZF.out 2>&1
python3 r5_mincover.py PA 400 2 > r5_mincover_PA.out 2>&1
python3 r5_mincover.py ZF 300 3 > r5_mincover_ZF.out 2>&1
python3 r5b_walk.py PA 400 4    > r5b_walk_PA.out 2>&1
python3 r5b_walk.py ZF 400 5    > r5b_walk_ZF.out 2>&1
python3 r6_align.py             > r6_align.out 2>&1
python3 r7_e9distinct.py        > r7_e9distinct.out 2>&1
python3 r8_leak.py              > r8_leak.out 2>&1
python3 r9_e5amb.py             > r9_e5amb.out 2>&1
python3 r10_mist.py             > r10_mist.out 2>&1
python3 r11_mutation.py         > r11_mutation.out 2>&1
python3 r12_trunc.py            > r12_trunc.out 2>&1
python3 r13_strip.py            > r13_strip.out 2>&1
python3 r14_pamist.py           > r14_pamist.out 2>&1
python3 r15_pafalse.py          > r15_pafalse.out 2>&1
python3 r16_numerals.py         > r16_numerals.out 2>&1
python3 r17_pattern.py          > r17_pattern.out 2>&1
echo done
