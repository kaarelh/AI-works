#!/usr/bin/env bash
# Quick end-to-end check of the inferential-learning code and computations:
#   1. the unit tests                                   (~1.5 min)
#   2. the --quick mode of every experiment             (~4 min on 4 cores)
#   3. --report-only regeneration of the FULL-grid reports from the saved JSON (seconds;
#      the multi-hour grids are NOT rerun; `git diff results/` should then be empty)
#   4. the theory / literature check scripts under ../research   (~8 min; see README.md)
# Total about 16 minutes on a 4-core machine (measured in the review: 55 steps, all PASS).
#
# Usage:   ./run_all_quick.sh                 # everything
#          SKIP_THEORY=1 ./run_all_quick.sh   # code only
#          FULL_THEORY=1 ./run_all_quick.sh   # also the slow theory scripts (adds roughly 30 min)
#          WORKERS=2 LOG_DIR=/some/dir ./run_all_quick.sh
# Exit status: 0 iff every step succeeded.  A per-step PASS/FAIL summary is printed at the end;
# the full output of every step is in $LOG_DIR (default: a fresh temporary directory).
#
# The quick modes write results/*_quick.* (they never touch the full-grid files).
# "PASS" for a theory script means it ran to completion without an exception; several scripts
# print their checks for a human to read rather than asserting them (README.md, "Theory check scripts").

set -u
HERE="$(cd "$(dirname "$0")" && pwd)"
RESEARCH="$(cd "$HERE/../research" && pwd)"
WORKERS="${WORKERS:-3}"
LOG_DIR="${LOG_DIR:-$(mktemp -d "${TMPDIR:-/tmp}/cil_quick_XXXXXX")}"
mkdir -p "$LOG_DIR"
SUMMARY="$LOG_DIR/summary.txt"
: > "$SUMMARY"
FAILED=0

step() {   # step NAME DIR TIMEOUT_S CMD...
    local name="$1" dir="$2" tmo="$3"; shift 3
    local log="$LOG_DIR/$(echo "$name" | tr ' /:' '___').log"
    local t0=$(date +%s)
    ( cd "$dir" && timeout "$tmo" "$@" ) > "$log" 2>&1
    local rc=$?
    local dt=$(( $(date +%s) - t0 ))
    local st="PASS"
    if [ $rc -ne 0 ]; then st="FAIL(rc=$rc)"; FAILED=$((FAILED + 1)); fi
    printf "%-14s %5ss  %s\n" "$st" "$dt" "$name" | tee -a "$SUMMARY"
}

echo "logs: $LOG_DIR"

# 1. unit tests
step "pytest" "$HERE" 1200 python3 -m pytest -q

# 2. quick modes
step "A algebra --quick" "$HERE" 1200 python3 experiments/exp_algebra_learning.py --quick --workers "$WORKERS"
step "B prop --quick" "$HERE" 1200 python3 experiments/exp_prop_learning.py --quick --workers "$WORKERS"
step "C adversarial --quick" "$HERE" 1200 python3 experiments/exp_adversarial_prover.py --quick --workers "$WORKERS"
step "C adversarial --quick --retrain" "$HERE" 1200 python3 experiments/exp_adversarial_prover.py --quick --retrain --workers "$WORKERS"

# 3. full-grid reports from the saved JSON (no recomputation)
step "A algebra --report-only" "$HERE" 600 python3 experiments/exp_algebra_learning.py --report-only
step "B prop --report-only" "$HERE" 600 python3 experiments/exp_prop_learning.py --report-only
step "C adversarial --report-only" "$HERE" 600 python3 experiments/exp_adversarial_prover.py --report-only

# 4. theory and literature checks
if [ -z "${SKIP_THEORY:-}" ]; then
    T="$RESEARCH/theory"
    for d in T1-code T4-checks T6-checks; do
        step "theory $d/run_all.sh" "$T/$d" 1800 sh run_all.sh
    done
    run_py() {   # run_py DIR SCRIPT [ARGS...]
        local d="$1" f="$2"; shift 2
        step "$(basename "$d")/$f" "$d" 900 python3 "$f" "$@"
    }
    for f in carnap_check.py fallacy_check.py matrix_check.py repair_checks.py; do run_py "$T/T2-checks" "$f"; done
    for f in drag_sign.py hygiene.py learn_regions.py leg_exact.py pendulum.py projectile.py realizability.py \
             realizability_deep.py realizability_frame.py realizability_sup.py realizability_uninformative.py \
             sps_checker.py; do run_py "$T/T3-checks" "$f"; done
    for f in c1_user_example.py c2_pricing_and_kink.py c3_rate_threshold.py c4_rules_toy.py \
             c5_incontext_persona.py repair_checks.py; do run_py "$T/T5-checks" "$f"; done
    for f in depth_nonmono.py duality.py hilbert_blame.py ind_lgg.py ind_sub_lgg.py lemma61.py matrix_witness.py \
             noisefree.py overlap.py prop32_voting.py thm56_finite_d.py ttl_sim.py two_point_bounds.py; do
        run_py "$T/T7-checks" "$f"
    done
    run_py "$T/T1-code" rho.py
    run_py "$T/T1-code" ville.py
    run_py "$RESEARCH/lit/L11-scripts" coherence_checks.py
    run_py "$RESEARCH/lit/L3-scripts" axiom_induction_coherence.py
    run_py "$RESEARCH/lit/L3-scripts" sigma2_weak_coherence.py
    for f in ballistics.py protostar.py leg.py leg2.py; do run_py "$RESEARCH/lit/L9-scripts" "$f"; done
    if [ -n "${FULL_THEORY:-}" ]; then
        run_py "$T/T7-checks" matrix4.py
        run_py "$T/T1-code" thm31b_counterexample.py
        run_py "$T/T1-code" elast.py "{'a':0,'b':0,'g':1,'p':2}" 4 2
        run_py "$T/T1-code" abstr2.py 2 4 15
        run_py "$T/T1-code" icclimb.py 9 6000 11 3
        run_py "$T/T3-checks" leg_mc_flux.py
    fi
fi

echo
echo "==== summary ($FAILED failed) ====  logs: $LOG_DIR"
cat "$SUMMARY"
[ "$FAILED" -eq 0 ]
