#!/bin/bash
# Out-of-sample targets: 20 fresh random formulas (boolfuncs.make_random_suite), d = 30, 2 seeds; runs after the d-scaling sweep.
S=/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad
cd "$(dirname "$0")"
while kill -0 409 2>/dev/null; do sleep 10; done   # PID of run_dscale.sh in this session
SUITE=random python3 nn_train.py --protocol fixed --opt adam --lr 1e-3 --steps 20000 --seeds 0,1 --out $S/results_random
echo RANDOM_DONE
