#!/bin/bash
# Composition test, second batch: extra controls at d = 30, and the main targets at d = 60 (does the gap grow with d?).
S=/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad
cd "$(dirname "$0")"
export SUITE=poly
while kill -0 $1 2>/dev/null; do sleep 20; done
python3 nn_train.py --protocol fixed --opt adam --lr 1e-3 --steps 20000 --seeds 0,1,2 --fns compG,compH --out $S/results_comp
DIM=60 python3 nn_train.py --protocol fixed --opt adam --lr 1e-3 --steps 20000 --seeds 0,1 --fns compA,compB,compC,compF \
    --ns 64,128,256,512,1024,2048,4096,8192,16384,32768 --out $S/results_comp_d60
echo COMP2_DONE
