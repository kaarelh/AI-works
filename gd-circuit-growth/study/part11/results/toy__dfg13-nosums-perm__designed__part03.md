## dfg13-nosums-perm on the designed suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| stair5 | 109 | 1514 | -3.80 | 0.42 / 0.01 / 0.00 / 0.00 ; 0.45 / 0.36 / 0.23 / 0.00 | 1.4e-01 |
| majpar | 62 | 1380 | -4.49 | 0.08 / 0.00 / 0.00 / 0.00 ; 0.47 / 0.33 / 0.12 / 0.00 | 1.4e-01 |
| parmaj | 223 | 743 | -1.73 | 0.51 / 0.00 / 0.00 / 0.00 ; 0.48 / 0.34 / 0.02 / 0.00 | 1.4e-01 |
| mux | 71 | 1156 | -4.02 | 0.12 / 0.00 / 0.00 / 0.00 ; 0.43 / 0.35 / 0.12 / 0.00 | 1.4e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 2 of 44 (parmaj@64: 0.51 vs 0.48; parmaj@128: 0.51 vs 0.44). Of these, by more than 2 standard errors of the seed-to-seed spread: 1 (parmaj@128).

Mean log2 ratio over targets where both learn: -3.51 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 4; clearly worse: 0; of 4. Largest compute used: 1.4e-01 of a GD run.

