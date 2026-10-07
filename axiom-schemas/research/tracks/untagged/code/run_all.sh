#!/bin/sh
# Re-run every computation of notes-final.md (track "untagged"); outputs next to the scripts.
# v1 outputs (before the referee) are kept in v1_outputs/.
cd "$(dirname "$0")"
python3 -u u_test_refuters.py      > u_test_refuters.out
python3 -u u0_crossval_mincov.py 20 > u0_crossval_mincov.out   # ~3 min; needs ../../../prior/induction
python3 -u u1_pa_cross.py          > u1_pa_cross.out
python3 -u u2_threshold.py         > u2_threshold.out
python3 -u u3_dtrc_pa.py           > u3_dtrc_pa.out
python3 -u u4_zf_cross.py          > u4_zf_cross.out
python3 -u u5_dtrc_zf.py           > u5_dtrc_zf.out             # ~2.5 min (part B second run); u5b is the fast version
python3 -u u5b_bootstrap.py        > u5b_bootstrap.out
python3 -u u6_forall_nontrans.py   > u6_forall_nontrans.out
python3 -u u7_mdl.py 200 1000 4000 16000 64000 > u7_mdl.out
python3 -u u8_noise.py             > u8_noise.out
python3 -u u9_clean_fragmentation.py > u9_clean_fragmentation.out
python3 -u u10_zfc_choice.py       > u10_zfc_choice.out
python3 -u u12_headclass.py        > u12_headclass.out          # ~7 min
python3 -u u13_monotone_check.py 14 > u13_monotone_check.out    # uses ../referee_code/ref_enum.py (referee's enumerator)
python3 -u u14_passes_check.py      > u14_passes_check.out      # every DTRC run reaches the audit fixpoint on pass 1
