#!/bin/bash
L=/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/std/p8
P="taskset -c 2,3 nice -n 19 env OPENBLAS_NUM_THREADS=1 OMP_NUM_THREADS=1"
cd /home/user/AI-works/gd-circuit-growth/study/standard_tasks
$P python3 baselines.py hgb texture churn wine_quality_white page_blocks clean2 led24 ann_thyroid banana krkopt sleep > $L/refs_hgb_new.log 2>&1
$P python3 baselines.py linear texture churn wine_quality_white page_blocks clean2 led24 ann_thyroid banana krkopt sleep > $L/refs_linear_new.log 2>&1
cd /home/user/AI-works/gd-circuit-growth/study/hybrid
for s in random dlheld dlheld2 dlheld3; do $P python3 eval_toy.py refs:HGB $s > $L/refs_toy_$s.log 2>&1; done
echo done > $L/refs.done
