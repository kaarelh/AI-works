#!/bin/bash
# Ablations of DFG on the designed suite (d = 30), each removing one ingredient taken from the networks.  Run from this
# folder; results/<name>__designed.{json,md}.
export OPENBLAS_NUM_THREADS=1
run() { python3 run_eval.py "dfg:DFG:$1" designed > /dev/null 2>&1; echo "done $1"; }
run '{"name": "abl-coef-readout", "readout": "coef"}' &
run '{"name": "abl-label-noise", "noise": "label"}' &
wait
run '{"name": "abl-no-composition", "max_ext_bases": 0, "local_max": 0}' &
run '{"name": "abl-no-blocks", "blocks": false}' &
wait
run '{"name": "abl-K3", "K": 3}' &
run '{"name": "abl-no-small-n", "small_n": false}' &
wait
