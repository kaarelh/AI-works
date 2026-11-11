## dfg13-labelnoise-perm on the dlheld6 suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| h6_00 | never | never | +nan | 0.42 / 0.38 / 0.35 / 0.34 ; 0.45 / 0.44 / 0.44 / 0.45 | 1.4e-01 |
| h6_01 | 430 | 3071 | -2.84 | 0.40 / 0.40 / 0.00 / 0.00 ; 0.44 / 0.44 / 0.40 / 0.01 | 1.8e-01 |
| h6_02 | 417 | 1869 | -2.16 | 0.50 / 0.33 / 0.00 / 0.00 ; 0.49 / 0.50 / 0.41 / 0.01 | 1.5e-01 |
| h6_03 | 197 | 323 | -0.71 | 0.29 / 0.01 / 0.00 / 0.00 ; 0.30 / 0.14 / 0.00 / 0.00 | 1.5e-01 |
| h6_04 | 50 | 116 | -1.20 | 0.03 / 0.03 / 0.00 / 0.00 ; 0.16 / 0.05 / 0.01 / 0.00 | 1.5e-01 |
| h6_05 | 42 | 78 | -0.88 | 0.08 / 0.04 / 0.01 / 0.00 ; 0.12 / 0.04 / 0.02 / 0.00 | 1.8e-01 |
| h6_06 | 223 | 3726 | -4.06 | 0.51 / 0.00 / 0.01 / 0.00 ; 0.50 / 0.50 / 0.48 / 0.05 | 1.5e-01 |
| h6_07 | 708 | 3215 | -2.18 | 0.38 / 0.28 / 0.00 / 0.00 ; 0.40 / 0.31 / 0.25 / 0.05 | 2.0e-01 |
| h6_08 | 407 | 3119 | -2.94 | 0.33 / 0.26 / 0.00 / 0.00 ; 0.36 / 0.29 / 0.26 / 0.03 | 1.5e-01 |
| h6_09 | 413 | 1450 | -1.81 | 0.39 / 0.27 / 0.01 / 0.01 ; 0.41 / 0.31 / 0.16 / 0.01 | 3.0e-01 |
| h6_10 | 216 | 1414 | -2.71 | 0.36 / 0.02 / 0.00 / 0.00 ; 0.39 / 0.34 / 0.18 / 0.00 | 1.4e-01 |
| h6_11 | 106 | 881 | -3.05 | 0.38 / 0.00 / 0.00 / 0.00 ; 0.36 / 0.33 / 0.05 / 0.00 | 1.6e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 6 of 132 (h6_00@16: 0.49 vs 0.43; h6_00@32: 0.47 vs 0.44; h6_01@32: 0.48 vs 0.46; h6_03@128: 0.26 vs 0.23; h6_10@32: 0.40 vs 0.37; h6_11@16: 0.43 vs 0.37). Of these, by more than 2 standard errors of the seed-to-seed spread: 0.

Mean log2 ratio over targets where both learn: -2.23 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 11; clearly worse: 0; of 12. Largest compute used: 3.0e-01 of a GD run.

