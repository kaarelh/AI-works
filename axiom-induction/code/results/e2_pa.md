# E2: unlabelled PA mixture, posterior over the pool

Command: `cd code/experiments && python3 e2_pa.py`. Seeds 0-24; n in [8, 16, 32, 64, 128, 256, 512]. Generator: L0 citations from T* = Q1..Q7 + T_Ind with fixed weights 0.05 (each Q axiom) and 0.65 (T_Ind); motives from the default Grammar (one hole, no parameter). Likelihood L0 with the same Q (well specified), Dirichlet alpha = 0.5, prior 2^-bits. Causal pool (build points 8, 16, 32, 64) with Trim(T, D_n) and Mem(D_n). Verifier view at citation depth (K = 0): "P(|-held-out Ind)" is the mean posterior mass of theories that cite each of 6 held-out induction instances (not in the training stream); "max P(|-false)" the largest mass deriving one of 5 false probes (0=S0, Ax x+0=0, induction with a wrong base, Ax Sx=x, Ax Ay y=x).

Wall time 52 s.


## Pool at the largest n (seed 0; trimmed theories and Mem(D_n) are added at each n)

| theory | class | equivalent to T* | sound | bits | components |
|---|---|---|---|---|---|
| T* | true | yes | True | 226.2 | 8 |
| frag-complete | fragmented | yes | True | 925.1 | 16 |
| frag-atoms | fragmented | weaker | True | 364.2 | 9 |
| T*-Q1 | sub-T* | weaker | True | 211.4 | 7 |
| T*-Q2 | sub-T* | weaker | True | 193.0 | 7 |
| T*-Q3 | sub-T* | yes | True | 194.0 | 7 |
| T*-Q4 | sub-T* | weaker | True | 211.0 | 7 |
| T*-Q5 | sub-T* | weaker | True | 192.0 | 7 |
| T*-Q6 | sub-T* | weaker | True | 212.0 | 7 |
| T*-Q7 | sub-T* | weaker | True | 187.2 | 7 |
| spare-nested(T_and) | spare | yes | True | 313.8 | 9 |
| spare-true(0+x=x) | spare | yes | True | 239.2 | 9 |
| spare-false(0=1) | spare | no | False | 230.4 | 9 |
| IndSwap (equivalent, uncited) | equivalent-uncited | yes | True | 226.2 | 8 |
| Ind-any-base | over-general | no | False | 228.0 | 8 |
| Ind-any-antecedent | over-general | no | False | 202.1 | 8 |
| bare?P | over-general | no | False | 5.7 | 1 |
| Q-lumped | over-general | no | False | 77.4 | 3 |
| frag-observed@8 | fragmented | yes | True | 506.1 | 11 |
| skel4@8 | skeleton | weaker | True | 119.4 | 3 |
| skel6@8 | skeleton | weaker | True | 473.4 | 6 |
| frag-observed@16 | fragmented | yes | True | 593.5 | 12 |
| skel4@16 | skeleton | weaker | True | 135.5 | 4 |
| skel6@16 | skeleton | weaker | True | 191.3 | 5 |
| skel8@16 | skeleton | no | False | 535.5 | 8 |
| skel4@32 | skeleton | no | False | 115.1 | 4 |
| skel6@32 | skeleton | weaker | True | 199.0 | 6 |
| skel8@32 | skeleton | weaker | True | 254.3 | 7 |
| Q+min0@32 | min | unknown | True | 213.9 | 8 |
| frag-observed@64 | fragmented | yes | True | 756.5 | 14 |
| skel4@64 | skeleton | no | False | 77.4 | 3 |
| skel6@64 | skeleton | no | False | 141.2 | 6 |
| Q+min5@64 | min | no | False | 235.6 | 8 |


Motive roots in the data (seed 0, all n): {'imp': 39, 'not': 36, '<': 70, 'and': 39, '=': 108, 'iff': 6, 'all': 13, 'or': 14, 'ex': 9}


First occurrence (datum index) of each axiom, seeds 0-4: seed 0: {'Ind': 1, 'Q7': 2, 'Q2': 6, 'Q4': 15, 'Q5': 19, 'Q3': 32, 'Q1': 47, 'Q6': 64}; seed 1: {'Q3': 1, 'Ind': 2, 'Q6': 8, 'Q1': 11, 'Q5': 12, 'Q4': 13, 'Q7': 32, 'Q2': 37}; seed 2: {'Ind': 1, 'Q1': 2, 'Q6': 6, 'Q5': 8, 'Q2': 28, 'Q7': 34, 'Q4': 64, 'Q3': 65}; seed 3: {'Q5': 1, 'Ind': 2, 'Q7': 5, 'Q6': 14, 'Q1': 18, 'Q3': 19, 'Q4': 23, 'Q2': 54}; seed 4: {'Q5': 1, 'Q3': 2, 'Ind': 3, 'Q2': 6, 'Q1': 10, 'Q4': 15, 'Q7': 17, 'Q6': 26}


## Posterior mass (means over 25 seeds), causal pool


Columns: T*; tagged deductively equivalent to T* (incl. T*); sound and strictly weaker; unsound; unknown; Mem(D_n); mean mass citing a held-out induction instance; mean of the largest mass citing a false probe; seeds in which a delta = 0.05 verifier accepts a false probe; MAP [tag] (count).


| n | T* | equiv. | weaker | unsound | unknown | Mem | P(|-held-out Ind) | max P(|-false) | accepting seeds | MAP (count) |
|---|---|---|---|---|---|---|---|---|---|---|
| 8 | 2e-21 | 4e-13 | 0.744 | 0.256 | 2e-65 | 2e-24 | 1.000 | 0.256 | 2/25 | skel4@8 [weaker] x12; DTRC@8 [weaker] x6; trim:Q-lumped [no] x4; Q-lumped [no] x2 |
| 16 | 9e-07 | 5e-06 | 0.803 | 0.197 | 0 | 4e-161 | 1.000 | 0.197 | 3/25 | skel6@16 [weaker] x9; skel4@16 [weaker] x5; Q-lumped [no] x3; DTRC@8 [weaker] x3 |
| 32 | 0.197 | 0.197 | 0.727 | 0.077 | 0 | 0 | 1.000 | 0.077 | 0/25 | T*-Q2 [weaker] x7; skel6@32 [weaker] x6; T* [yes] x5; T*-Q7 [weaker] x2 |
| 64 | 0.751 | 0.791 | 0.200 | 0.009 | 0 | 0 | 1.000 | 0.009 | 0/25 | T* [yes] x19; T*-Q3 [yes] x1; T*-Q1 [weaker] x1; T*-Q4 [weaker] x1 |
| 128 | 0.991 | 0.991 | 0 | 0.009 | 0 | 0 | 1.000 | 0.009 | 0/25 | T* [yes] x25 |
| 256 | 0.994 | 0.994 | 0 | 0.006 | 0 | 0 | 1.000 | 0.006 | 0/25 | T* [yes] x25 |
| 512 | 0.996 | 0.996 | 0 | 0.004 | 0 | 0 | 1.000 | 0.004 | 0/25 | T* [yes] x25 |


## SeenQ(D_n) = Trim(T*, D_n): the Q axioms cited in D_n plus T_Ind

Columns: mean number of Q axioms seen; mean posterior of SeenQ; code length of SeenQ minus that of Q-lumped (bits; negative = SeenQ preferred; mean and range over seeds); the name under which SeenQ is in the pool (a data-derived or hand theory with the same components keeps its own name).


| n | Q axioms seen | posterior of SeenQ | SeenQ - Q-lumped (bits) | name in the pool (count) |
|---|---|---|---|---|
| 8 | 2.48 | 0.744 | -16.8 (-49.1 to 8.9) | skel4@8 x15; DTRC@8 x10 |
| 16 | 4.04 | 0.803 | -38.1 (-92.8 to 12.7) | skel6@16 x14; skel4@16 x5; DTRC@8 x3; skel4@8 x2 |
| 32 | 5.68 | 0.923 | -87.6 (-169.7 to -25.1) | skel6@32 x7; T*-Q2 x7; T* x5; T*-Q7 x2 |
| 64 | 6.72 | 0.991 | -255.0 (-446.3 to -122.4) | T* x19; T*-Q3 x1; T*-Q1 x1; T*-Q4 x1 |
| 128 | 7.00 | 0.991 | -635.4 (-905.4 to -374.2) | T* x25 |
| 256 | 7.00 | 0.994 | -1393.5 (-1703.7 to -1081.1) | T* x25 |
| 512 | 7.00 | 0.996 | -2928.5 (-3294.6 to -2572.9) | T* x25 |


## Legacy pool (data-derived theories from the first 16, 40, 64 data; no trimmed theories) against the causal pool


| n | accepting seeds, legacy | accepting seeds, causal | unsound mass, legacy (mean) | unsound mass, causal (mean) | unsound MAP, legacy | unsound MAP, causal |
|---|---|---|---|---|---|---|
| 8 | 18/25 | 2/25 | 0.720 | 0.256 | 18/25 | 7/25 |
| 16 | 3/25 | 3/25 | 0.147 | 0.197 | 4/25 | 5/25 |
| 32 | 2/25 | 0/25 | 0.081 | 0.077 | 2/25 | 1/25 |
| 64 | 0/25 | 0/25 | 0.009 | 0.009 | 0/25 | 0/25 |
| some n <= 64 | 19/25 | 5/25 |  |  |  |  |


Seeds 0-4 only: accepting at some n <= 64: legacy [1, 2, 4], causal [1, 4].


## Seeds and n at which a delta = 0.05 verifier accepts a false probe (causal pool)


| seed | n | MAP | its mass | accepted false probes |
|---|---|---|---|---|
| 1 | 16 | skel4@16 | 0.999 | Ax.x+0=0, Ax.Sx=x, Ax.Ay.y=x |
| 4 | 16 | Q-lumped | 0.998 | Ax.x+0=0, Ax.Sx=x, Ax.Ay.y=x |
| 11 | 16 | Q-lumped | 0.999 | Ax.x+0=0, Ax.Sx=x, Ax.Ay.y=x |
| 14 | 8 | trim:Q-lumped | 1.000 | Ax.x+0=0, Ax.Sx=x, Ax.Ay.y=x |
| 17 | 8 | Q-lumped | 0.996 | Ax.x+0=0, Ax.Sx=x, Ax.Ay.y=x |


## Code length minus that of T* (bits; mean over the seeds where both are finite; negative = preferred to T*)


| n | frag-complete | spare-nested(T_and) | spare-true(0+x=x) | spare-false(0=1) | Q-lumped | bare?P | Ind-any-base | Ind-any-antecedent | Mem |
|---|---|---|---|---|---|---|---|---|---|
| 8 | 696.9 | 87.6 | 13.8 | 5.1 | -100.0 | 435.8 | 146.9 | 537.9 | 529.2 |
| 16 | 698.2 | 87.9 | 14.2 | 5.4 | -41.0 | 960.2 | 252.8 | 957.9 | 1078.6 |
| 32 | 700.0 | 88.2 | 14.6 | 5.9 | 51.8 | 2233.1 | 530.9 | 2043.6 | 2433.9 |
| 64 | 703.6 | 88.5 | 15.1 | 6.3 | 248.2 | 4656.8 | 1046.8 | 4085.5 | 4900.3 |
| 128 | 708.2 | 88.8 | 15.6 | 6.8 | 635.4 | 9234.0 | 2010.6 | 7904.8 | 9384.4 |
| 256 | 711.7 | 89.0 | 16.1 | 7.3 | 1393.5 | 18854.4 | 4071.6 | 16015.0 | 18656.0 |
| 512 | 716.3 | 89.2 | 16.6 | 7.8 | 2928.5 | 38502.1 | 8302.5 | 32623.9 | 37329.8 |
