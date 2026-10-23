#!/bin/bash
# d-scaling study: the same networks and protocol at input dimension 15 and 60 (d = 30 is the main sweep).
S=/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad
cd "$(dirname "$0")"
FNS=par2,par3,par4,stair5,mux,majpar,maj9
DIM=15 python3 nn_train.py --protocol fixed --opt adam --lr 1e-3 --steps 20000 --seeds 0,1 --fns $FNS \
    --ns 16,32,64,128,256,512,1024,2048,4096,8192,16384 --out $S/results_d15
DIM=60 python3 nn_train.py --protocol fixed --opt adam --lr 1e-3 --steps 20000 --seeds 0,1 --fns $FNS \
    --ns 16,32,64,128,256,512,1024,2048,4096,8192,16384,32768,65536 --out $S/results_d60
echo DSCALE_DONE
