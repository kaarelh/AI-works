#!/bin/bash
# usage: sweep.sh logfile fns "kw1" "kw2" ...
log=$1; fns=$2; shift 2
for kw in "$@"; do
  OMP_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 python3 calib.py --kw "$kw" --fns $fns --seeds ${SEEDS:-0} 2>&1 | grep -v Warn >> $log
done
echo SWEEP_DONE >> $log
