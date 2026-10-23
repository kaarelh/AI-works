#!/bin/bash
# Full NN sweep.  Raw results go to $OUT (large; kept outside the repo).
OUT=${OUT:-/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/results}
mkdir -p $OUT
cd "$(dirname "$0")"
python3 nn_train.py --protocol fixed  --opt adam --lr 1e-3 --steps 20000 --out $OUT
python3 nn_train.py --protocol online --opt adam --lr 1e-3 --steps 40000 --seeds 0,1,2,3,4 --out $OUT
python3 nn_train.py --protocol fixed  --opt sgd  --lr 0.2  --steps 20000 --out $OUT
python3 nn_train.py --protocol online --opt sgd  --lr 0.2  --steps 40000 --seeds 0,1,2,3,4 --out $OUT
echo ALL_DONE
