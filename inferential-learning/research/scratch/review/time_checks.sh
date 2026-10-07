#!/bin/bash
# time every individual theory/lit check script (cwd = its directory), timeout 900 s each
R=/home/user/AI-works/inferential-learning/research
OUT=/tmp/claude-0/-home-user-AI-works/c4435474-536f-5a96-a73c-7d0c5ea93659/scratchpad/review_logs/indiv
mkdir -p $OUT
: > $OUT/summary.tsv
run() { # dir script args...
  d=$1; shift; f=$1; shift
  s=$(date +%s.%N)
  ( cd $R/$d && timeout 900 python3 $f "$@" ) > "$OUT/$(echo $d | tr / _)__$f.log" 2>&1
  rc=$?
  e=$(date +%s.%N)
  printf "%s\t%s\t%s\t%s\t%.1f\n" "$d" "$f" "$*" "$rc" "$(echo "$e - $s" | bc)" >> $OUT/summary.tsv
}
for f in carnap_check.py fallacy_check.py matrix_check.py repair_checks.py; do run theory/T2-checks $f; done
for f in drag_sign.py hygiene.py learn_regions.py leg_exact.py pendulum.py projectile.py realizability.py realizability_deep.py realizability_frame.py realizability_sup.py realizability_uninformative.py sps_checker.py; do run theory/T3-checks $f; done
for f in c1_user_example.py c2_pricing_and_kink.py c3_rate_threshold.py c4_rules_toy.py c5_incontext_persona.py repair_checks.py; do run theory/T5-checks $f; done
for f in depth_nonmono.py duality.py hilbert_blame.py ind_lgg.py ind_sub_lgg.py lemma61.py matrix_witness.py noisefree.py overlap.py prop32_voting.py thm56_finite_d.py ttl_sim.py two_point_bounds.py matrix4.py; do run theory/T7-checks $f; done
for f in rho.py ville.py; do run theory/T1-code $f; done
run lit/L11-scripts coherence_checks.py
run lit/L3-scripts axiom_induction_coherence.py
run lit/L3-scripts sigma2_weak_coherence.py
for f in ballistics.py protostar.py leg.py leg2.py; do run lit/L9-scripts $f; done
echo DONE >> $OUT/summary.tsv
