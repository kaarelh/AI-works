## dfg13-core-perm on the dlheld6 suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| h6_00 | never | never | +nan | 0.34 / 0.34 / 0.34 / 0.34 ; 0.45 / 0.44 / 0.44 / 0.45 | 7.7e-03 |
| h6_01 | 428 | 3071 | -2.84 | 0.39 / 0.39 / 0.00 / 0.00 ; 0.44 / 0.44 / 0.40 / 0.01 | 7.2e-03 |
| h6_02 | 414 | 1869 | -2.18 | 0.50 / 0.31 / 0.00 / 0.00 ; 0.49 / 0.50 / 0.41 / 0.01 | 7.8e-02 |
| h6_03 | 188 | 323 | -0.78 | 0.35 / 0.01 / 0.00 / 0.00 ; 0.30 / 0.14 / 0.00 / 0.00 | 1.0e-02 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 4 of 44 (h6_01@32: 0.50 vs 0.46; h6_03@16: 0.47 vs 0.41; h6_03@32: 0.47 vs 0.36; h6_03@64: 0.35 vs 0.30). Of these, by more than 2 standard errors of the seed-to-seed spread: 1 (h6_03@32).

Mean log2 ratio over targets where both learn: -1.93 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 3; clearly worse: 0; of 4. Largest compute used: 7.8e-02 of a GD run.

