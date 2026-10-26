#!/bin/bash
# Remaining stronger-MLP runs: Part 7 tabular set, n <= 10000.  Two lanes split the list (no dataset in both).
S=/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad
L=$S/hybrid/jaxlogs
CPUS=$1; shift
cd /home/user/AI-works/gd-circuit-growth/study/standard_tasks
for ds in "$@"; do
  if [ ! -f $L/strong_$ds.done ]; then
    MLP_MAX_N=10000 MLP_RESUME=1 MLP_SEED0_FROM=30000 taskset -c $CPUS python3 mlp_strong.py $ds > $L/strong_$ds.log 2>&1 && touch $L/strong_$ds.done
  fi
done
touch $L/lane3_$CPUS.done
