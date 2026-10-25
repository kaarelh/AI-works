#!/bin/bash
# Held-out targets for the trajectory models: run ONLY after every model's predict.py is frozen.
S=/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/traj
cd "$(dirname "$0")/.."
for f in andxor dlist5 parmaj dnf3 rand1 rand3; do
  python3 trajectories/run_traj.py $f $S --ns 512,2048,16384 --seeds 0,1,2 --steps 20000
  python3 trajectories/run_traj.py $f $S --seeds 0,1,2 --steps 20000 --online
done
echo HELDOUT_DONE
