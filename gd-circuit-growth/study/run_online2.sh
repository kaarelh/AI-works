#!/bin/bash
# Online protocol rerun with prequential-mistake logging (for the online-to-batch bound); runs after run_width.sh.
S=/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad
cd "$(dirname "$0")"
while kill -0 2629 2>/dev/null; do sleep 10; done   # PID of run_width.sh in this session
python3 nn_train.py --protocol online --opt adam --lr 1e-3 --steps 20000 --seeds 0,1,2 --out $S/results_online2 \
    --fns par2,par3,maj9,stair5,majpar,mux
echo ONLINE2_DONE
