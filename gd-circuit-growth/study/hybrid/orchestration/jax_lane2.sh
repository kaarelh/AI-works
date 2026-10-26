#!/bin/bash
# Part 8 stronger GD references, reordered (headline references first).  One JAX job at a time.
S=/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad
L=$S/hybrid/jaxlogs; mkdir -p $L
CPUS=${CPUS:-2,3}
# the designed-suite weight-decay run started by jax_lane.sh: wait for it, then mark it done if complete
while pgrep -f "nn_train.py --protocol fixed --opt adam --wd 0.1 --fns all --seeds 0,1,2 --out $S/results_wd0.1" > /dev/null; do sleep 30; done
[ $(ls $S/results_wd0.1/fixed_adam_*.npz 2>/dev/null | wc -l) -ge 21 ] && touch $L/nets_wd_designed.done
nets() {  # suite variant-flags suffix tag
  local suite=$1 flags=$2 suf=$3 tag=$4
  local out=$S/results_${suite}${suf}; [ $suite = designed ] && out=$S/results${suf}
  local seeds=0,1,2; [ $suite = random ] && seeds=0,1
  cd /home/user/AI-works/gd-circuit-growth/study
  if [ ! -f $L/${tag}_$suite.done ]; then
    SUITE=$([ $suite = designed ] && echo "" || echo $suite) taskset -c $CPUS python3 nn_train.py --protocol fixed --opt adam $flags --fns all --seeds $seeds --out $out > $L/${tag}_$suite.log 2>&1 && touch $L/${tag}_$suite.done
  fi
}
strong() {  # dataset [max_n]
  cd /home/user/AI-works/gd-circuit-growth/study/standard_tasks
  if [ ! -f $L/strong_$1.done ]; then
    MLP_MAX_N=$2 MLP_RESUME=1 MLP_SEED0_FROM=30000 taskset -c $CPUS python3 mlp_strong.py $1 > $L/strong_$1.log 2>&1 && touch $L/strong_$1.done
  fi
}
nets designed "--wd 0.1" _wd0.1 nets_wd
for ds in banana churn page_blocks ann_thyroid led24 wine_quality_white texture clean2 krkopt sleep; do strong $ds; done
for ds in mnist fashion_mnist; do strong $ds; done
nets dlheld3 "--loss logistic --wd 0.1" _cewd0.1 nets_cewd
for ds in optdigits magic kr_vs_kp satimage spambase; do strong $ds; done
for s in dlheld2 dlheld random; do nets $s "--wd 0.1" _wd0.1 nets_wd; done
nets designed "--loss logistic --wd 0.1" _cewd0.1 nets_cewd
for ds in ring twonorm phoneme dna waveform_40 pendigits mushroom nursery letter adult connect_4; do strong $ds 10000; done
touch $L/jax_lane.done
