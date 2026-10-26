#!/bin/sh
# Run study/hybrid/eval_toy.py (unchanged) on the p9_sum learner: puts study/part9 on PYTHONPATH so that
# 'p9_sum.learner:Learner' resolves; pinned to cores 0-1, single-threaded BLAS.
# usage: sh run_toy.sh <designed|dlsymdev> [fns] [--perm] [--quick] [--part=K]
#   e.g. sh run_toy.sh dlsymdev --perm --quick          (development)
#        sh run_toy.sh designed --perm                  (full dev evaluation, 3 seeds, n = 16 ... 16384)
# Results: study/hybrid/results/toy__p9_sum-perm__<suite>[__quick][__partK].json (+ .md); shards: merge_toy.py p9_sum-perm <suite>
HERE=$(cd "$(dirname "$0")" && pwd); HYB="$HERE/../../hybrid"
cd "$HYB" && PYTHONPATH="$HERE/..:$PYTHONPATH" taskset -c 0,1 nice -n 5 env OPENBLAS_NUM_THREADS=1 OMP_NUM_THREADS=1 \
  python3 eval_toy.py p9_sum.learner:Learner "$@"
