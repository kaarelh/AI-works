#!/bin/bash
# Re-run a sample of the history and examples check scripts on scratch copies and diff against saved outputs.
M=/home/user/AI-works/solomonoff-function-induction/research/paper-review/scratch/p1-math-B/mirror
L=/home/user/AI-works/solomonoff-function-induction/research/paper-review/scratch/p1-math-B/rerun_log.txt
: > $L
cd $M/research/tracks/history/checks
for s in c1_brief_counterexample c5_gf_agreement c6_set_order_lemma; do
  { s0=$(date +%s); python3 -I $s.py > $s.out 2>>$L; echo "$s %e s $(( $(date +%s)-s0 )) s" >> $L; }
done
{ s0=$(date +%s); python3 -I c9_normalised_lower_bounds.py > /dev/null 2>>$L; echo "c9 %e s $(( $(date +%s)-s0 )) s" >> $L; }
cd $M/research/tracks/history/referee_code
{ s0=$(date +%s); python3 -I r4_combinatorial_lemmas.py > r4_combinatorial_lemmas.out 2>>$L; echo "r4 %e s $(( $(date +%s)-s0 )) s" >> $L; }
cd $M/research/tracks/examples/checks
for s in e3_cyclic e7_eisenstat_dp e1_eisenstat_exact e6_cyclic_sharp; do
  { s0=$(date +%s); python3 $s.py > $s.stdout 2>>$L; echo "$s %e s $(( $(date +%s)-s0 )) s" >> $L; }
done
echo DONE >> $L
