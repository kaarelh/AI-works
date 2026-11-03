## dfg13-lenient-perm on the dlheld6 suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| h6_00 | never | never | +nan | 0.45 / 0.42 / 0.36 / 0.34 ; 0.45 / 0.44 / 0.44 / 0.45 | 1.4e-01 |
| h6_01 | 365 | 3071 | -3.07 | 0.42 / 0.20 / 0.00 / 0.00 ; 0.44 / 0.44 / 0.40 / 0.01 | 1.9e-01 |
| h6_02 | 414 | 1869 | -2.17 | 0.50 / 0.31 / 0.00 / 0.00 ; 0.49 / 0.50 / 0.41 / 0.01 | 3.7e-01 |
| h6_03 | 130 | 323 | -1.31 | 0.31 / 0.03 / 0.00 / 0.00 ; 0.30 / 0.14 / 0.00 / 0.00 | 1.6e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 2 of 44 (h6_00@32: 0.46 vs 0.44; h6_01@16: 0.46 vs 0.43). Of these, by more than 2 standard errors of the seed-to-seed spread: 0.

Mean log2 ratio over targets where both learn: -2.19 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 3; clearly worse: 0; of 4. Largest compute used: 3.7e-01 of a GD run.

