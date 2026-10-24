#!/bin/bash
# Refine the d = 120 3-parity crossing, which the factor-2 grid puts between n = 8192 (error 0.48) and 16384 (0):
# n = 2^13.25, 2^13.5, 2^13.75 on the same nested training sets (prefixes of the same data stream), 2 seeds.
S=/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad
cd /home/user/AI-works/gd-circuit-growth/study
export DIM=120 OPENBLAS_NUM_THREADS=1 OMP_NUM_THREADS=1
python3 nn_train.py --protocol fixed --opt adam --lr 1e-3 --steps 40000 --seeds 0,1 --fns par3 \
    --ns 9742,11585,13777 --out $S/results_d120_refine
echo REFINE_DONE
