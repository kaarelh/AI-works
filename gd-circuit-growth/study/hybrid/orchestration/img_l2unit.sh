#!/bin/bash
L=/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/std/p8
cd /home/user/AI-works/gd-circuit-growth/study/standard_tasks
MLP_VARIANT=l2unit taskset -c 2,3 python3 mlp_large.py mnist > $L/l2unit_mnist60k.log 2>&1
MLP_VARIANT=l2unit MLP_MAX_N=30000 taskset -c 2,3 python3 mlp.py fashion_mnist > $L/l2unit_fmnist.log 2>&1
MLP_VARIANT=l2unit taskset -c 2,3 python3 mlp_large.py fashion_mnist >> $L/l2unit_fmnist.log 2>&1
echo done > $L/img_l2unit.done
