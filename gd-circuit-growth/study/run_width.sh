#!/bin/bash
# Width robustness: the same protocol at widths 32 and 512 (main sweep: 128) on four targets, 2 seeds; runs after run_random.sh.
S=/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad
cd "$(dirname "$0")"
while kill -0 2621 2>/dev/null || kill -0 409 2>/dev/null; do sleep 10; done   # PIDs of run_random.sh and run_dscale.sh in this session
for W in 32 512; do
  WIDTH=$W python3 nn_train.py --protocol fixed --opt adam --lr 1e-3 --steps 20000 --seeds 0,1 --fns par3,maj9,mux,stair5 \
      --out $S/results_w$W
done
echo WIDTH_DONE
