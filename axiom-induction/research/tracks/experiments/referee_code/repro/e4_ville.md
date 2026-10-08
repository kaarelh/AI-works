# E4: adaptive prover against the threshold verifier

Command: `cd code/experiments && python3 e4_ville.py`. Dirichlet alpha = 0.5; derivability |-_1 (chain derivations of length <= 1). Wall time 1270 s.


## (A) Tight construction: T* = {phi(?t)}, P(t=0) = 1-u (numerals), T' = {phi(0), 0=S0}

delta = w* delta'. The prover queries 0=S0 in every round. Win = some round accepts it. The bound is delta' (= delta / w*). "exact" = (1-u)^t* with t* the first n at which pi(T*|phi(0)^n) <= delta (with the Dirichlet factor of T').


| data | u | w* | delta' | delta | t* | MC win rate (closed form, 1e5 streams) | full pipeline wins | exact | bound |
|---|---|---|---|---|---|---|---|---|---|
| well specified | 0.05 | 0.01 | 0.01 | 0.00010 | 150 | 46/100000 = 0.00046 | 0/400 | 0.00046 | 0.01 |
| selected: phi(0) only | 0.05 | 0.01 | 0.01 | 0.00010 | 150 | - | 20/20 | 1 | 0.01 |
| well specified | 0.01 | 0.001 | 0.05 | 0.00005 | 680 | 123/100000 = 0.00123 | not run (t* > 200) | 0.00108 | 0.05 |
| selected: phi(0) only | 0.01 | 0.001 | 0.05 | 0.00005 | 680 | - | 20/20 | 1 | 0.05 |
| well specified | 0.5 | 0.01 | 0.01 | 0.00010 | 10 | 95/100000 = 0.00095 | 2/400 | 0.00098 | 0.01 |
| selected: phi(0) only | 0.5 | 0.01 | 0.01 | 0.00010 | 10 | - | 20/20 | 1 | 0.01 |
| well specified | 0.1 | 0.1 | 0.1 | 0.01000 | 47 | 694/100000 = 0.00694 | 5/400 | 0.00707 | 0.1 |
| selected: phi(0) only | 0.1 | 0.1 | 0.1 | 0.01000 | 47 | - | 20/20 | 1 | 0.1 |
| well specified | 0.2 | 0.05 | 0.2 | 0.01000 | 17 | 2298/100000 = 0.02298 | 6/400 | 0.02252 | 0.2 |
| selected: phi(0) only | 0.2 | 0.05 | 0.2 | 0.01000 | 17 | - | 20/20 | 1 | 0.2 |


## (B, C) Pool experiments (phi = x+0=x; T* = H_sch; delta = 0.05 w*, so the bound is 0.05)

B: well specified (L0 citations of phi(?t)). C1: 10% of the data replaced by false near misses t+0=St; the pool also contains {phi(?t), ?t+0=S?t}. C2: heavy-tailed terms (zeta numerals, s = 1.5). C3: only phi(0) is shown; the decoy T' = {phi(0), 0=S0} is in the pool. The prover queries every round all statements of a fixed list that T* does not derive: Ax.x+0=x, 1+0=0, 0+0=1, 1+0=0, 0=1, 2+0=3, SSSSSSS0+0=SSSSSSSS0, 1+1+0=S(1+1), 0=0. n = 1..256. "max mass" = the largest posterior mass ever given to the theories deriving one invalid query.


| setting | likelihood | w* = prior of T* | prover wins | bound | max mass on an invalid query | MAP at n=256 (count) | first wins (examples) |
|---|---|---|---|---|---|---|---|
| B | L0 | 7e-06 | 0/100 | 0.05 | 0.4524 | H_sch x100 |  |
| B | L1 | 7e-06 | 0/100 | 0.05 | 0.5329 | H_sch x100 |  |
| C1 | L0 | 7e-06 | 100/100 | 0.05 | 1.0000 | sch+mistake-schema x100 | n=36 0+0=1; n=9 0+0=1 |
| C1 | L1 | 7e-06 | 100/100 | 0.05 | 1.0000 | sch+mistake-schema x100 | n=36 0+0=1; n=9 0+0=1 |
| C2 | L0 | 7e-06 | 0/100 | 0.05 | 0.4524 | spare_nested x96; H_sch x4 |  |
| C2 | L1 | 7e-06 | 0/100 | 0.05 | 0.5358 | spare_nested x96; H_sch x4 |  |
| C3 | L0 | 7e-06 | 0/100 | 0.05 | 0.1072 | Mem x100 |  |
| C3 | L1 | 7e-06 | 0/100 | 0.05 | 0.1120 | Mem x100 |  |
