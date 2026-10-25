#!/bin/bash
# Ablations of DFG v1.1 (readout "logit", inputs permuted per fit) on 7 designed targets (d = 30), each removing one
# ingredient.  Run from this folder; writes results/<name>__designed.{json,md}.
export OPENBLAS_NUM_THREADS=1
FNS=maj9,thr10,par4,stair5,mux,rmaj9,sparsepoly
run() { python3 run_eval.py "dfg:DFG:$1" designed $FNS > /dev/null 2>&1; echo "done $1"; }
run '{"name": "abl-full", "readout": "logit", "permute": true}' &
run '{"name": "abl-ls-readout", "readout": "ls", "permute": true}' &
run '{"name": "abl-coef-readout", "readout": "coef", "permute": true}' &
run '{"name": "abl-label-noise", "readout": "logit", "noise": "label", "permute": true}' &
wait
run '{"name": "abl-no-composition", "readout": "logit", "max_ext_bases": 0, "local_max": 0, "permute": true}' &
run '{"name": "abl-no-blocks", "readout": "logit", "blocks": false, "permute": true}' &
run '{"name": "abl-K3-no-hi", "readout": "logit", "K": 3, "K_hi": 3, "permute": true}' &
run '{"name": "abl-no-background-no-small-n", "readout": "logit", "background": false, "small_n": false, "permute": true}' &
wait
