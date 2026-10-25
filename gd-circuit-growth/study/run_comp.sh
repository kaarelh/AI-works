#!/bin/bash
# Composition test (user's question): networks on the real-valued targets of boolfuncs.make_poly_suite, d = 30, Adam.
S=/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad
cd "$(dirname "$0")"
export SUITE=poly
python3 nn_train.py --protocol fixed --opt adam --lr 1e-3 --steps 20000 --seeds 0,1,2 --fns compA,compB,compC,compD,compE,compF,compL --out $S/results_comp
for f in compA compB compC compE compF; do
  python3 nn_train.py --protocol online --opt adam --lr 1e-3 --steps 20000 --seeds 0,1,2 --fns $f --out $S/results_comp
done
echo COMP_DONE
