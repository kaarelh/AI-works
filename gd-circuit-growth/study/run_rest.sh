#!/bin/bash
# Remainder of the NN sweep, trimmed to the time budget: online Adam (3 seeds, 20000 steps) on six functions.
# The fixed-protocol SGD pass was dropped for time.
OUT=${OUT:-/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/results}
cd "$(dirname "$0")"
while kill -0 1022 2>/dev/null; do sleep 10; done
python3 nn_train.py --protocol online --opt adam --lr 1e-3 --steps 20000 --seeds 0,1,2 --out $OUT \
    --fns par2,par3,maj9,stair5,majpar,mux
echo ALL_DONE
