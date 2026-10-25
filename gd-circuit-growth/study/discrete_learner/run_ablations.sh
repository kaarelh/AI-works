#!/bin/bash
# Ablations of DFG v1.1 (readout "logit") on 12 designed targets (d = 30), each removing one ingredient.
# Run from this folder; writes results/<name>__designed.{json,md}.
export OPENBLAS_NUM_THREADS=1
FNS=dict,maj9,thr10,par3,par4,stair5,majpar,parmaj,mux,dnf3,rmaj9,sparsepoly
run() { python3 run_eval.py "dfg:DFG:$1" designed $FNS > /dev/null 2>&1; echo "done $1"; }
run '{"name": "abl-full", "readout": "logit"}' &
run '{"name": "abl-ls-readout-v1", "readout": "ls"}' &
run '{"name": "abl-coef-readout", "readout": "coef"}' &
run '{"name": "abl-label-noise", "readout": "logit", "noise": "label"}' &
wait
run '{"name": "abl-no-composition", "readout": "logit", "max_ext_bases": 0, "local_max": 0}' &
run '{"name": "abl-no-blocks", "readout": "logit", "blocks": false}' &
run '{"name": "abl-K3-no-hi", "readout": "logit", "K": 3, "K_hi": 3}' &
run '{"name": "abl-no-background-no-small-n", "readout": "logit", "background": false, "small_n": false}' &
wait
