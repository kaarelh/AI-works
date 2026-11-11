## dfg13-K3-perm on the dlheld6 suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| h6_00 | never | never | +nan | 0.42 / 0.38 / 0.35 / 0.34 ; 0.45 / 0.44 / 0.44 / 0.45 | 1.1e-02 |
| h6_01 | 430 | 3071 | -2.84 | 0.40 / 0.40 / 0.00 / 0.00 ; 0.44 / 0.44 / 0.40 / 0.01 | 9.6e-03 |
| h6_02 | 407 | 1869 | -2.20 | 0.50 / 0.30 / 0.00 / 0.00 ; 0.49 / 0.50 / 0.41 / 0.01 | 2.0e-01 |
| h6_03 | 157 | 323 | -1.04 | 0.29 / 0.00 / 0.00 / 0.00 ; 0.30 / 0.14 / 0.00 / 0.00 | 1.6e-02 |
| h6_04 | 76 | 116 | -0.61 | 0.12 / 0.03 / 0.00 / 0.00 ; 0.16 / 0.05 / 0.01 / 0.00 | 1.9e-02 |
| h6_05 | 42 | 78 | -0.88 | 0.08 / 0.00 / 0.00 / 0.00 ; 0.12 / 0.04 / 0.02 / 0.00 | 1.3e-01 |
| h6_06 | 223 | 3726 | -4.06 | 0.51 / 0.00 / 0.00 / 0.00 ; 0.50 / 0.50 / 0.48 / 0.05 | 1.3e-02 |
| h6_07 | 358 | 3215 | -3.17 | 0.38 / 0.19 / 0.00 / 0.00 ; 0.40 / 0.31 / 0.25 / 0.05 | 5.1e-02 |
| h6_08 | 765 | 3119 | -2.03 | 0.33 / 0.21 / 0.00 / 0.00 ; 0.36 / 0.29 / 0.26 / 0.03 | 5.7e-02 |
| h6_09 | 353 | 1450 | -2.04 | 0.39 / 0.18 / 0.01 / 0.00 ; 0.41 / 0.31 / 0.16 / 0.01 | 2.9e-01 |
| h6_10 | 216 | 1414 | -2.71 | 0.36 / 0.02 / 0.00 / 0.00 ; 0.39 / 0.34 / 0.18 / 0.00 | 8.7e-03 |
| h6_11 | 106 | 881 | -3.05 | 0.38 / 0.00 / 0.00 / 0.00 ; 0.36 / 0.33 / 0.05 / 0.00 | 2.5e-02 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 5 of 132 (h6_00@16: 0.49 vs 0.43; h6_00@32: 0.47 vs 0.44; h6_01@32: 0.48 vs 0.46; h6_10@32: 0.40 vs 0.37; h6_11@16: 0.43 vs 0.37). Of these, by more than 2 standard errors of the seed-to-seed spread: 0.

Mean log2 ratio over targets where both learn: -2.24 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 11; clearly worse: 0; of 12. Largest compute used: 2.9e-01 of a GD run.

