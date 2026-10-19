#!/usr/bin/env bash
# Reproduce the sign-GP numerics end to end (about an hour on four CPUs).
# Each step is deterministic given its seeds (single-threaded BLAS).  results.jsonl is appended and
# resumable: delete it first for a clean rerun.
set -euo pipefail
cd "$(dirname "$0")"
export OMP_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 MKL_NUM_THREADS=1
gcc -O3 -march=native -shared -fPIC -o hmc_orthant.so hmc_orthant.c -lm
python3 search_leap1.py          # leap / threshold-degree census of 4-bit (exhaustive) and 5-bit (random) juntas
python3 pick_leap1.py            # classes of leap-1, threshold-degree-3 4-juntas; writes leap1_choice.json
python3 targets.py               # Fourier degree, weights, threshold degree, leap -> targets.json
python3 ptf_disagreement.py      # eps_r = min degree-r PTF disagreement (MILP) -> ptf_disagreement.json
python3 validate_sampler.py      # HMC vs exact orthant ratios (n=8) and vs coordinatewise Gibbs (n=150..300)
ORIG="parity_full parity2 parity3 parity4 maj7 and3 stair4 leap1_td3 rand4 stair5"
# main grid; RNG streams are keyed by (d,L,seed,n,target), so splitting invocations gives the same draws
python3 run_sweep.py --workers 4 --L 2 3 --d 10 12 --seeds 0 1 2 3 4 --targets $ORIG \
  --ngrid 25 50 100 150 200 300 400 600 800 --n_keep 1500 --burn 300
# large-n extension at d=12
python3 run_sweep.py --workers 4 --L 2 --d 12 --seeds 0 1 2 --targets $ORIG --ngrid 1200 1600 2400 \
  --n_keep 1500 --burn 300
python3 run_sweep.py --workers 2 --L 3 --d 12 --seeds 0 1 --targets $ORIG --ngrid 2400 --n_keep 1500 --burn 300
# the leap-one target x4 ? x1x2x3 : MAJ(x1,x2,x3), added afterwards at d=12, L=2
python3 run_sweep.py --workers 3 --L 2 --d 12 --seeds 0 1 2 3 4 --targets cond_par3_maj3 \
  --ngrid 100 200 400 800 --n_keep 1500 --burn 300
python3 run_sweep.py --workers 3 --L 2 --d 12 --seeds 0 1 2 --targets cond_par3_maj3 --ngrid 1600 2400 \
  --n_keep 1500 --burn 300
python3 energy_diag.py           # Gaussian-energy mechanism check (d=12, L=2, seed 0)
python3 summarize.py             # -> summary.txt, summary.csv
