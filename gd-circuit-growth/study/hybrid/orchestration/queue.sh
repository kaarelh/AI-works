#!/bin/bash
# Part 8 baseline queue: one JAX job at a time (memory), cores 2-3.
cd /home/user/AI-works/gd-circuit-growth/study/standard_tasks
L=/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/std/p8
MLP_VARIANT=l2 MLP_RESUME=1 taskset -c 2,3 python3 mlp.py optdigits magic kr_vs_kp satimage spambase > $L/mlp_l2_dev.log 2>&1
cd /home/user/AI-works/gd-circuit-growth/study
mkdir -p /tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/std/results_dlheld3
SUITE=dlheld3 taskset -c 2,3 python3 nn_train.py --protocol fixed --opt adam --fns all --out /tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/std/results_dlheld3 > $L/nets_dlheld3.log 2>&1
cd /home/user/AI-works/gd-circuit-growth/study/standard_tasks
NEW="texture churn wine_quality_white page_blocks clean2 led24 ann_thyroid banana krkopt sleep"
taskset -c 2,3 python3 mlp.py $NEW > $L/mlp_new.log 2>&1
MLP_VARIANT=l2 MLP_RESUME=1 taskset -c 2,3 python3 mlp.py $NEW > $L/mlp_l2_new.log 2>&1
MLP_VARIANT=l2 MLP_RESUME=1 taskset -c 2,3 python3 mlp.py ring dna waveform_40 mushroom nursery twonorm adult phoneme pendigits letter connect_4 > $L/mlp_l2_old.log 2>&1
MLP_VARIANT=l2unit taskset -c 2,3 python3 mlp.py mnist fashion_mnist > $L/mlp_l2unit_img.log 2>&1
echo QUEUEDONE > $L/queue.done
