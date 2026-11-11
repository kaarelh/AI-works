#!/bin/bash
# DFG at d = 15, 60, 120 on the targets the networks were trained on there (seeds 0, 1).  Run from this folder.
export OPENBLAS_NUM_THREADS=1
for d in 15 60 120; do python3 run_eval.py dfg:DFG designed_d$d > /dev/null 2>&1 & done; wait; echo done
