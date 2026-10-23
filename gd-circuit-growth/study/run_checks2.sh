#!/bin/bash
# Two quick checks of the noise law (after the main session's sweeps):
#  (1) width 32 on the 4-parity (is a ~ best initial overlap among the hidden units, growing with width?);
#  (2) muP-SGD on the 3-parity at d = 15 and 60 (does the d^(k-1) scaling hold for SGD as well as Adam?).
S=/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad
cd "$(dirname "$0")"
WIDTH=32 python3 nn_train.py --protocol fixed --opt adam --lr 1e-3 --steps 20000 --seeds 0,1 --fns par4 --out $S/results_w32
DIM=15 python3 nn_train.py --protocol fixed --opt sgd --lr 0.2 --steps 20000 --seeds 0,1 --fns par3 \
    --ns 16,32,64,128,256,512,1024,2048,4096,8192,16384 --out $S/results_d15
DIM=60 python3 nn_train.py --protocol fixed --opt sgd --lr 0.2 --steps 20000 --seeds 0,1 --fns par3 \
    --ns 16,32,64,128,256,512,1024,2048,4096,8192,16384,32768,65536 --out $S/results_d60
echo CHECKS2_DONE
