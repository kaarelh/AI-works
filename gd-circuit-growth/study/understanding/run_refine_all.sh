#!/bin/bash
# Refine coarse factor-2 crossings at quarter-octave n (prefixes of the same nested training sets), 20000 steps.
#  3-parity at d = 15, 30, 60 (so that its d-exponent is read on equally refined grids at every d, as at d = 120),
#  multiplexer at d = 120.
S=/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad
cd /home/user/AI-works/gd-circuit-growth/study
export OPENBLAS_NUM_THREADS=1 OMP_NUM_THREADS=1
DIM=15 python3 nn_train.py --protocol fixed --opt adam --lr 1e-3 --steps 20000 --seeds 0,1 --fns par3 --ns 152,181,215 --out $S/results_d15_refine
DIM=30 python3 nn_train.py --protocol fixed --opt adam --lr 1e-3 --steps 20000 --seeds 0,1,2 --fns par3 --ns 609,724,861 --out $S/results_d30_refine
DIM=60 python3 nn_train.py --protocol fixed --opt adam --lr 1e-3 --steps 20000 --seeds 0,1 --fns par3 --ns 2435,2896,3444 --out $S/results_d60_refine
DIM=120 python3 nn_train.py --protocol fixed --opt adam --lr 1e-3 --steps 40000 --seeds 0,1 --fns mux --ns 4871,5793,6889 --out $S/results_d120_refine
echo REFINE_ALL_DONE
