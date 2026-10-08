# E2: unlabelled PA mixture, posterior over the pool

Command: `cd code/experiments && python3 e2_pa.py`. Seeds [0, 1, 2, 3, 4]; n in [8, 16, 32, 64, 128, 256, 512]. Generator: L0 citations from T* = Q1..Q7 + T_Ind with weights 0.05 (each Q axiom) and 0.65 (T_Ind); motives from the default Grammar (one hole, no parameter). Likelihood L0 with the same Q (well specified), Dirichlet alpha = 0.5, prior 2^-bits. Verifier view at citation depth (K = 0): "P(|-held-out Ind)" is the mean posterior mass of theories that cite each of 6 held-out induction instances; "max P(|-false)" the largest mass deriving one of 5 false probes (0=S0, Ax x+0=0, induction with a wrong base, Ax Sx=x, Ax Ay y=x).

Wall time 25 s.


## Pool (seed 0)

| theory | class | equivalent to T* | sound | bits | components |
|---|---|---|---|---|---|
| T* | true | yes | True | 226.2 | 8 |
| frag-complete | fragmented | yes | True | 925.1 | 16 |
| frag-observed64 | fragmented | yes | True | 756.5 | 14 |
| frag-atoms | over-specific | unknown | True | 364.2 | 9 |
| T*-Q1 | sub-T* | no | True | 211.4 | 7 |
| T*-Q2 | sub-T* | no | True | 193.0 | 7 |
| T*-Q3 | sub-T* | no | True | 194.0 | 7 |
| T*-Q4 | sub-T* | no | True | 211.0 | 7 |
| T*-Q5 | sub-T* | no | True | 192.0 | 7 |
| T*-Q6 | sub-T* | no | True | 212.0 | 7 |
| T*-Q7 | sub-T* | no | True | 187.2 | 7 |
| spare-nested(T_and) | spare | yes | True | 313.8 | 9 |
| spare-true(0+x=x) | spare | yes | True | 239.2 | 9 |
| spare-false(0=1) | spare | no | False | 230.4 | 9 |
| IndSwap (equivalent, uncited) | equivalent-uncited | yes | True | 226.2 | 8 |
| Ind-any-base | over-general | no | False | 228.0 | 8 |
| Ind-any-antecedent | over-general | no | False | 202.1 | 8 |
| bare?P | over-general | no | False | 5.7 | 1 |
| Q-lumped | over-general | no | False | 77.4 | 3 |
| skel4 | skeleton | no | False | 115.1 | 4 |
| skel6 | sub-T* | no | True | 199.0 | 6 |
| skel8 | sub-T* | no | True | 254.3 | 7 |
| DTRC(n=16) | sub-T* | no | True | 135.5 | 4 |
| Q+min0 | min | no | False | 235.6 | 8 |
| Mem(D_n) | mem | no | True | - | n distinct |


Motive roots in the data (seed 0, all n): {'imp': 39, 'not': 36, '<': 70, 'and': 39, '=': 108, 'iff': 6, 'all': 13, 'or': 14, 'ex': 9}


First occurrence (datum index) of each axiom, per seed: seed 0: {'Ind': 1, 'Q7': 2, 'Q2': 6, 'Q4': 15, 'Q5': 19, 'Q3': 32, 'Q1': 47, 'Q6': 64}; seed 1: {'Q3': 1, 'Ind': 2, 'Q6': 8, 'Q1': 11, 'Q5': 12, 'Q4': 13, 'Q7': 32, 'Q2': 37}; seed 2: {'Ind': 1, 'Q1': 2, 'Q6': 6, 'Q5': 8, 'Q2': 28, 'Q7': 34, 'Q4': 64, 'Q3': 65}; seed 3: {'Q5': 1, 'Ind': 2, 'Q7': 5, 'Q6': 14, 'Q1': 18, 'Q3': 19, 'Q4': 23, 'Q2': 54}; seed 4: {'Q5': 1, 'Q3': 2, 'Ind': 3, 'Q2': 6, 'Q1': 10, 'Q4': 15, 'Q7': 17, 'Q6': 26}


## Posterior mass (means over seeds [0, 1, 2, 3, 4])


| n | T* | equiv. to T* (incl. T*) | fragmented | spare | over-general | over-specific | sub-T* (unseen Q axioms dropped) | other skeleton/DTRC/min | Mem | unsound | P(|-held-out Ind) | max P(|-false) | MAP (count over seeds) |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 8 | 2e-26 | 2e-26 | 1e-188 | 7e-28 | 0.200 | 0 | 0.599 | 0.200 | 1e-79 | 0.401 | 1.000 | 0.401 | DTRC(n=16) x3; Q-lumped x2 |
| 16 | 8e-22 | 8e-22 | 4e-184 | 2e-23 | 0.200 | 0 | 0.601 | 0.200 | 4e-163 | 0.399 | 1.000 | 0.399 | DTRC(n=16) x3; Q-lumped x2 |
| 32 | 0.197 | 0.197 | 5e-170 | 0.003 | 2e-12 | 0 | 0.600 | 0.200 | 0 | 0.203 | 1.000 | 0.203 | T*-Q2 x2; skel6 x1; skel4 x1; T* x1 |
| 64 | 0.790 | 0.790 | 4e-160 | 0.010 | 2e-56 | 0 | 0.200 | 2e-34 | 0 | 0.010 | 1.000 | 0.010 | T* x4; T*-Q3 x1 |
| 128 | 0.991 | 0.991 | 8e-214 | 0.009 | 1e-153 | 0 | 0 | 2e-86 | 0 | 0.009 | 1.000 | 0.009 | T* x5 |
| 256 | 0.994 | 0.994 | 2e-214 | 0.006 | 0 | 0 | 0 | 2e-224 | 0 | 0.006 | 1.000 | 0.006 | T* x5 |
| 512 | 0.996 | 0.996 | 2e-215 | 0.004 | 0 | 0 | 0 | 0 | 0 | 0.004 | 1.000 | 0.004 | T* x5 |


## Code length minus that of T* (bits; mean over seeds; negative = preferred to T*)


| n | frag-complete | spare-nested(T_and) | spare-true(0+x=x) | spare-false(0=1) | Q-lumped | bare?P |
|---|---|---|---|---|---|---|
| 8 | 697.0 | 88.0 | 13.8 | 5.1 | -91.3 | 390.7 |
| 16 | 699.2 | 88.5 | 14.2 | 5.4 | -65.5 | 1078.0 |
| 32 | 702.0 | 88.6 | 14.6 | 5.9 | 20.9 | 2358.9 |
| 64 | 704.1 | 89.0 | 15.1 | 6.3 | 203.1 | 4703.5 |
| 128 | 708.4 | 89.4 | 15.6 | 6.8 | 578.9 | 9431.1 |
| 256 | 711.3 | 89.3 | 16.1 | 7.3 | 1340.5 | 18665.1 |
| 512 | 716.7 | 89.6 | 16.6 | 7.8 | 2941.0 | 37480.2 |


## Code lengths at n = 512 (bits; -log2 prior - log2 marginal likelihood), per seed


Difference to T* (positive = worse than T*):


| seed | T* | frag-complete | frag-observed64 | spare-nested(T_and) | spare-true(0+x=x) | spare-false(0=1) | Mem |
|---|---|---|---|---|---|---|---|
| 0 | 0 | 718.2 | inf | 88.6 | 16.6 | 7.8 | 38245.5 |
| 1 | 0 | 717.7 | inf | 89.6 | 16.6 | 7.8 | 34493.3 |
| 2 | 0 | 719.3 | inf | 89.6 | 16.6 | 7.8 | 35132.4 |
| 3 | 0 | 711.2 | inf | 90.1 | 16.6 | 7.8 | 33954.0 |
| 4 | 0 | 717.4 | inf | 90.1 | 16.6 | 7.8 | 39649.1 |
