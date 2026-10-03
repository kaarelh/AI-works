#!/bin/sh
# Reproduces the [computed] claims of T1-soundness-under-search.md (section 7).
cd "$(dirname "$0")"
echo "## single-schema (k=1) and 2-union escalation dimension on ground terms of size <= N (Thm 3.4, 3.7)"
for N in 3 4 5; do python3 elast.py "{'c':0,'g':1,'p':2}" $N 1 | sed -n 2p; python3 elast.py "{'c':0,'g':1,'p':2}" $N 2 | sed -n 2p; done
for N in 3 4; do python3 elast.py "{'a':0,'b':0,'g':1,'p':2}" $N 1 | sed -n 2p; done
python3 elast.py "{'a':0,'b':0,'g':1,'p':2}" 3 2 | sed -n 2p
python3 elast.py "{'a':0,'b':0,'g':1,'p':2}" 3 3 | sed -n 2p
echo "## (slow, ~minutes) python3 elast.py \"{'a':0,'b':0,'g':1,'p':2}\" 4 2   -> 13"
echo "## subcubes, k=2 (Thm 3.7(iii))"
for n in 2 3 4; do python3 subcube.py $n 2; done
echo "## partition abstraction attains 2^d-1 (Thm 3.7(ii) tightness of the method)"
python3 abstr2.py 2 3 7 | grep target
echo "## (slow) python3 abstr2.py 2 4 15"
echo "## Conjecture 3.8 evidence: hill-climbing  args: universe_size iters seed max_height"
echo "##   python3 icclimb.py 9 6000 11 3 ; python3 icclimb.py 12 3000 21 4 ; python3 icclimb.py 14 2000 31 5"
echo "## toy natural deduction: exact identification by per-rule lgg (Thm 5.3)"
python3 toy_nd.py
echo "## noise: collapse, trimming, systematic fallacy (Prop 6.1, Thm 6.2, Cor 6.5)"
python3 noise.py
echo "## Ville tightness (Prop 4.3)"
python3 ville2.py
echo "## added during verification"
echo "## Conj 3.8 tight at k=2: graphic matroid flats M(K_{h+1}) give C(h+1,2)"
python3 graphic.py
echo "## Remark after Thm 5.4: k=k'=2 identification despite zeta=0"
python3 union_remark.py
echo "## Thm 4.2(a) needs noise unforeseeable by the prover"
python3 prescient.py
echo "## (slow) python3 thm31b_counterexample.py  -- conditional acceptance 1 at a history of probability eps"
echo "## Thm 3.7(i) explicit sequences; Prop 3.5 Bell(n) forced escalations"
python3 checks37.py
