#!/bin/bash
# Remainder of the NN sweep after the fixed-Adam pass, trimmed for time: online Adam with 3 seeds on all
# functions; fixed-protocol SGD with 2 seeds on the held-out functions plus par4 and stair5.
OUT=${OUT:-/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/results}
cd "$(dirname "$0")"
while kill -0 1022 2>/dev/null; do sleep 10; done
python3 nn_train.py --protocol online --opt adam --lr 1e-3 --steps 30000 --seeds 0,1,2 --out $OUT
python3 nn_train.py --protocol fixed  --opt sgd  --lr 0.2  --steps 20000 --seeds 0,1 --out $OUT \
    --fns and3,maj9,par3,majpar,mux,dlist5,sparsepoly,rand1,rand3,par4,stair5
echo ALL_DONE
