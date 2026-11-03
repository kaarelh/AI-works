## dfg13-noblocks-perm on the dlheld6 suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| h6_00 | never | never | +nan | 0.44 / 0.40 / 0.36 / 0.34 ; 0.45 / 0.44 / 0.44 / 0.45 | 1.4e-01 |
| h6_01 | 431 | 3071 | -2.83 | 0.42 / 0.40 / 0.00 / 0.00 ; 0.44 / 0.44 / 0.40 / 0.01 | 1.7e-01 |
| h6_02 | 415 | 1869 | -2.17 | 0.50 / 0.32 / 0.00 / 0.00 ; 0.49 / 0.50 / 0.41 / 0.01 | 3.3e-01 |
| h6_03 | 181 | 323 | -0.83 | 0.29 / 0.02 / 0.00 / 0.00 ; 0.30 / 0.14 / 0.00 / 0.00 | 1.5e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 3 of 44 (h6_00@16: 0.47 vs 0.43; h6_00@32: 0.46 vs 0.44; h6_01@16: 0.46 vs 0.43). Of these, by more than 2 standard errors of the seed-to-seed spread: 0.

Mean log2 ratio over targets where both learn: -1.94 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 3; clearly worse: 0; of 4. Largest compute used: 3.3e-01 of a GD run.

