## dfg13-K3-perm on the dlheld6 suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| h6_00 | never | never | +nan | 0.42 / 0.38 / 0.35 / 0.34 ; 0.45 / 0.44 / 0.44 / 0.45 | 1.1e-02 |
| h6_01 | 430 | 3071 | -2.84 | 0.40 / 0.40 / 0.00 / 0.00 ; 0.44 / 0.44 / 0.40 / 0.01 | 9.6e-03 |
| h6_02 | 407 | 1869 | -2.20 | 0.50 / 0.30 / 0.00 / 0.00 ; 0.49 / 0.50 / 0.41 / 0.01 | 2.0e-01 |
| h6_03 | 157 | 323 | -1.04 | 0.29 / 0.00 / 0.00 / 0.00 ; 0.30 / 0.14 / 0.00 / 0.00 | 1.6e-02 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 3 of 44 (h6_00@16: 0.49 vs 0.43; h6_00@32: 0.47 vs 0.44; h6_01@32: 0.48 vs 0.46). Of these, by more than 2 standard errors of the seed-to-seed spread: 0.

Mean log2 ratio over targets where both learn: -2.02 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 3; clearly worse: 0; of 4. Largest compute used: 2.0e-01 of a GD run.

