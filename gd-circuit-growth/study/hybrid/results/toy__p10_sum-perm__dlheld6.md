## p10_sum-perm on the dlheld6 suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| h6_00 | never | never | +nan | 0.36 / 0.36 / 0.34 / 0.34 ; 0.45 / 0.44 / 0.44 / 0.45 | 1.9e-01 |
| h6_01 | 430 | 3071 | -2.84 | 0.41 / 0.40 / 0.00 / 0.00 ; 0.44 / 0.44 / 0.40 / 0.01 | 2.6e-01 |
| h6_02 | 389 | 1869 | -2.26 | 0.49 / 0.24 / 0.00 / 0.00 ; 0.49 / 0.50 / 0.41 / 0.01 | 4.6e-01 |
| h6_03 | 98 | 323 | -1.72 | 0.21 / 0.00 / 0.00 / 0.00 ; 0.30 / 0.14 / 0.00 / 0.00 | 2.1e-01 |
| h6_04 | 29 | 116 | -1.98 | 0.07 / 0.00 / 0.00 / 0.00 ; 0.16 / 0.05 / 0.01 / 0.00 | 2.1e-01 |
| h6_05 | 33 | 78 | -1.26 | 0.04 / 0.01 / 0.00 / 0.00 ; 0.12 / 0.04 / 0.02 / 0.00 | 5.2e-01 |
| h6_06 | 349 | 3726 | -3.42 | 0.50 / 0.18 / 0.00 / 0.00 ; 0.50 / 0.50 / 0.48 / 0.05 | 2.1e-01 |
| h6_07 | 447 | 3215 | -2.85 | 0.37 / 0.21 / 0.01 / 0.00 ; 0.40 / 0.31 / 0.25 / 0.05 | 3.1e-01 |
| h6_08 | 449 | 3119 | -2.80 | 0.32 / 0.15 / 0.00 / 0.00 ; 0.36 / 0.29 / 0.26 / 0.03 | 3.9e-01 |
| h6_09 | 380 | 1450 | -1.93 | 0.40 / 0.21 / 0.01 / 0.00 ; 0.41 / 0.31 / 0.16 / 0.01 | 7.1e-01 |
| h6_10 | 206 | 1414 | -2.78 | 0.33 / 0.01 / 0.00 / 0.00 ; 0.39 / 0.34 / 0.18 / 0.00 | 2.0e-01 |
| h6_11 | 184 | 881 | -2.26 | 0.30 / 0.00 / 0.00 / 0.00 ; 0.36 / 0.33 / 0.05 / 0.00 | 2.3e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 4 of 132 (h6_01@32: 0.49 vs 0.46; h6_07@16: 0.46 vs 0.44; h6_08@16: 0.47 vs 0.41; h6_10@16: 0.35 vs 0.33). Of these, by more than 2 standard errors of the seed-to-seed spread: 0.

Mean log2 ratio over targets where both learn: -2.37 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 11; clearly worse: 0; of 12. Largest compute used: 7.1e-01 of a GD run.

