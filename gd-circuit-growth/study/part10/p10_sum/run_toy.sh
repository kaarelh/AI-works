#!/bin/sh
# usage: sh study/part10/p10_sum/run_toy.sh <suite> [targets] --perm [--part=K]   (hybrid/eval_toy.py, unchanged)
S=$(cd "$(dirname "$0")/../.." && pwd)
cd "$S/hybrid" && OMP_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 PYTHONPATH="$S/part10:$S/part9" exec python3 eval_toy.py p10_sum.learner:Learner "$@"
