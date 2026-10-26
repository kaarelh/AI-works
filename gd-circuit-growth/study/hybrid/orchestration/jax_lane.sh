#!/bin/bash
# Part 8 stronger GD references (after the fairness audit), one JAX job at a time.
S=/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad
L=$S/hybrid/jaxlogs; mkdir -p $L
CPUS=${CPUS:-2,3}
cd /home/user/AI-works/gd-circuit-growth/study
# toy networks with decoupled weight decay 0.1 (square loss), same grid, seeds, steps and width
for suite in dlheld3 designed dlheld2 dlheld random; do
  out=$S/results_${suite}_wd0.1; [ $suite = designed ] && out=$S/results_wd0.1
  seeds=0,1,2; [ $suite = random ] && seeds=0,1
  if [ ! -f $L/nets_wd_$suite.done ]; then
    SUITE=$([ $suite = designed ] && echo "" || echo $suite) taskset -c $CPUS python3 nn_train.py --protocol fixed --opt adam --wd 0.1 --fns all --seeds $seeds --out $out > $L/nets_wd_$suite.log 2>&1 && touch $L/nets_wd_$suite.done
  fi
done
cd /home/user/AI-works/gd-circuit-growth/study/standard_tasks
for ds in banana churn page_blocks ann_thyroid led24 wine_quality_white texture clean2 krkopt sleep mnist fashion_mnist optdigits magic kr_vs_kp satimage spambase; do
  if [ ! -f $L/strong_$ds.done ]; then
    MLP_RESUME=1 MLP_SEED0_FROM=30000 taskset -c $CPUS python3 mlp_strong.py $ds > $L/strong_$ds.log 2>&1 && touch $L/strong_$ds.done
  fi
done
cd /home/user/AI-works/gd-circuit-growth/study
for suite in dlheld3 designed; do
  out=$S/results_${suite}_cewd0.1; [ $suite = designed ] && out=$S/results_cewd0.1
  if [ ! -f $L/nets_cewd_$suite.done ]; then
    SUITE=$([ $suite = designed ] && echo "" || echo $suite) taskset -c $CPUS python3 nn_train.py --protocol fixed --opt adam --loss logistic --wd 0.1 --fns all --out $out > $L/nets_cewd_$suite.log 2>&1 && touch $L/nets_cewd_$suite.done
  fi
done
cd /home/user/AI-works/gd-circuit-growth/study/standard_tasks
for ds in ring twonorm phoneme dna waveform_40 pendigits mushroom nursery letter adult connect_4; do
  if [ ! -f $L/strong_$ds.done ]; then
    MLP_RESUME=1 MLP_SEED0_FROM=30000 taskset -c $CPUS python3 mlp_strong.py $ds > $L/strong_$ds.log 2>&1 && touch $L/strong_$ds.done
  fi
done
touch $L/jax_lane.done
