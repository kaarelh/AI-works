#!/bin/sh
# Re-run the referee's oracle-soundness and Min checks against the v2 code (from this directory).
set -e
cd "$(dirname "$0")"
export PYTHONDONTWRITEBYTECODE=1
python3 r3_record.py PA         > r3_record_PA.out 2>&1
python3 r3_record.py ZF         > r3_record_ZF.out 2>&1
python3 r3_check.py PA          > r3_check_PA.out 2>&1
python3 r3_check.py ZF          > r3_check_ZF.out 2>&1
python3 r3b_deep.py             > r3b_deep.out 2>&1
python3 r4_fuzz.py PA 3000 2    > r4_fuzz_PA.out 2>&1
python3 r4_fuzz.py ZF 600 5     > r4_fuzz_ZF.out 2>&1
python3 r11_mutation.py         > r11_mutation.out 2>&1
python3 r15_pafalse.py          > r15_pafalse.out 2>&1
echo done
