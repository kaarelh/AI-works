#!/bin/bash
# Second JAX lane (cores 0-1): the network reference variants, while the secondary designs' jobs are paused.
S=/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad
L=$S/hybrid/jaxlogs
nets() {
  local suite=$1 flags=$2 suf=$3 tag=$4
  local out=$S/results_${suite}${suf}; [ $suite = designed ] && out=$S/results${suf}
  local seeds=0,1,2; [ $suite = random ] && seeds=0,1
  cd /home/user/AI-works/gd-circuit-growth/study
  if [ ! -f $L/${tag}_$suite.done ] && [ ! -f $L/${tag}_$suite.running ]; then
    touch $L/${tag}_$suite.running
    SUITE=$([ $suite = designed ] && echo "" || echo $suite) taskset -c 0,1 python3 nn_train.py --protocol fixed --opt adam $flags --fns all --seeds $seeds --out $out > $L/${tag}_$suite.log 2>&1 && touch $L/${tag}_$suite.done
    rm -f $L/${tag}_$suite.running
  fi
}
nets dlheld3 "--loss logistic --wd 0.1" _cewd0.1 nets_cewd
for s in dlheld2 dlheld random; do nets $s "--wd 0.1" _wd0.1 nets_wd; done
nets designed "--loss logistic --wd 0.1" _cewd0.1 nets_cewd
touch $L/laneB.done
