#!/bin/bash
# Width dependence of the noise law's overlap constant a: parities of 3 and 4 bits at widths 64 and 256 (d = 30, Adam, 2 seeds),
# to go with widths 32 (run_width.sh, run_checks2.sh) and 128 (main sweep).
S=/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad
cd "$(dirname "$0")"
for W in 64 256; do
  WIDTH=$W nice python3 nn_train.py --protocol fixed --opt adam --lr 1e-3 --steps 20000 --seeds 0,1 --fns par3 --ns 128,256,512,1024,2048,4096 --out $S/results_w$W
  WIDTH=$W nice python3 nn_train.py --protocol fixed --opt adam --lr 1e-3 --steps 20000 --seeds 0,1 --fns par4 --ns 512,1024,2048,4096,8192 --out $S/results_w$W
done
echo WIDTH2_DONE
