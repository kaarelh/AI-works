## dfg13-K3-perm on the designed suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| stair5 | 114 | 1514 | -3.74 | 0.42 / 0.00 / 0.00 / 0.00 ; 0.45 / 0.36 / 0.23 / 0.00 | 9.5e-03 |
| majpar | 57 | 1380 | -4.59 | 0.07 / 0.00 / 0.00 / 0.00 ; 0.47 / 0.33 / 0.12 / 0.00 | 8.1e-03 |
| parmaj | 111 | 743 | -2.74 | 0.50 / 0.00 / 0.00 / 0.00 ; 0.48 / 0.34 / 0.02 / 0.00 | 8.4e-03 |
| mux | 55 | 1156 | -4.39 | 0.01 / 0.00 / 0.00 / 0.00 ; 0.43 / 0.35 / 0.12 / 0.00 | 8.1e-03 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 2 of 44 (stair5@32: 0.50 vs 0.47; mux@16: 0.50 vs 0.46). Of these, by more than 2 standard errors of the seed-to-seed spread: 0.

Mean log2 ratio over targets where both learn: -3.86 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 4; clearly worse: 0; of 4. Largest compute used: 9.5e-03 of a GD run.

