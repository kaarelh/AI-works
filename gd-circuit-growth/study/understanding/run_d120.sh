#!/bin/bash
# Out-of-sample d-scaling test at d = 120 (predictions frozen in predictions_d120.json before this run).
# Same networks and protocol as the main sweep (muP MLP width 128, Adam lr 1e-3, batch 64, fixed training set),
# 2 seeds; run to 40000 steps so that the protocol's 20000-step checkpoint and a 2x longer budget are both recorded.
S=/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad
cd /home/user/AI-works/gd-circuit-growth/study
export DIM=120 OPENBLAS_NUM_THREADS=1 OMP_NUM_THREADS=1
python3 nn_train.py --protocol fixed --opt adam --lr 1e-3 --steps 40000 --seeds 0,1 --fns par3 \
    --ns 512,1024,2048,4096,8192,16384,32768,65536 --out $S/results_d120
python3 nn_train.py --protocol fixed --opt adam --lr 1e-3 --steps 40000 --seeds 0,1 --fns par2,maj9 \
    --ns 64,128,256,512,1024,2048,4096,8192 --out $S/results_d120
python3 nn_train.py --protocol fixed --opt adam --lr 1e-3 --steps 40000 --seeds 0,1 --fns mux \
    --ns 256,512,1024,2048,4096,8192,16384,32768 --out $S/results_d120
echo D120_DONE
