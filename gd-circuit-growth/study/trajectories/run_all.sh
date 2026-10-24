#!/bin/bash
# Learning trajectories for five targets: fixed training sets n = 512, 2048, 16384 and one-pass (online), 3 seeds each.
S=/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/traj
cd "$(dirname "$0")/.."
for f in sparsepoly stair5 mux majpar rmaj9; do
  python3 trajectories/run_traj.py $f $S --ns 512,2048,16384 --seeds 0,1,2 --steps 20000
  python3 trajectories/run_traj.py $f $S --seeds 0,1,2 --steps 20000 --online
done
echo TRAJ_DONE
