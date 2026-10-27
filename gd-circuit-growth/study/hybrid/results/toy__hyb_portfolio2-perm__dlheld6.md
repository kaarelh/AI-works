## hyb_portfolio2-perm on the dlheld6 suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| h6_00 | never | never | +nan | 0.36 / 0.36 / 0.34 / 0.34 ; 0.45 / 0.44 / 0.44 / 0.45 | 1.9e-01 |
| h6_01 | 429 | 3071 | -2.84 | 0.41 / 0.39 / 0.00 / 0.00 ; 0.44 / 0.44 / 0.40 / 0.01 | 2.6e-01 |
| h6_02 | 428 | 1869 | -2.13 | 0.49 / 0.37 / 0.00 / 0.00 ; 0.49 / 0.50 / 0.41 / 0.01 | 5.3e-01 |
| h6_03 | 98 | 323 | -1.72 | 0.21 / 0.00 / 0.00 / 0.00 ; 0.30 / 0.14 / 0.00 / 0.00 | 2.1e-01 |
| h6_04 | 29 | 116 | -1.98 | 0.06 / 0.01 / 0.00 / 0.00 ; 0.16 / 0.05 / 0.01 / 0.00 | 2.0e-01 |
| h6_05 | 33 | 78 | -1.26 | 0.04 / 0.01 / 0.00 / 0.00 ; 0.12 / 0.04 / 0.02 / 0.00 | 6.5e-01 |
| h6_06 | 342 | 3726 | -3.45 | 0.50 / 0.17 / 0.00 / 0.00 ; 0.50 / 0.50 / 0.48 / 0.05 | 3.4e-01 |
| h6_07 | 678 | 3215 | -2.24 | 0.37 / 0.22 / 0.06 / 0.00 ; 0.40 / 0.31 / 0.25 / 0.05 | 5.3e-01 |
| h6_08 | 446 | 3119 | -2.81 | 0.31 / 0.18 / 0.00 / 0.00 ; 0.36 / 0.29 / 0.26 / 0.03 | 2.2e-01 |
| h6_09 | 392 | 1450 | -1.89 | 0.40 / 0.23 / 0.01 / 0.00 ; 0.41 / 0.31 / 0.16 / 0.01 | 6.0e-01 |
| h6_10 | 702 | 1414 | -1.01 | 0.33 / 0.31 / 0.00 / 0.00 ; 0.39 / 0.34 / 0.18 / 0.00 | 2.1e-01 |
| h6_11 | 208 | 881 | -2.08 | 0.30 / 0.00 / 0.00 / 0.00 ; 0.36 / 0.33 / 0.05 / 0.00 | 2.3e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 4 of 132 (h6_01@32: 0.49 vs 0.46; h6_07@16: 0.46 vs 0.44; h6_08@16: 0.47 vs 0.41; h6_10@16: 0.35 vs 0.33). Of these, by more than 2 standard errors of the seed-to-seed spread: 0.

Mean log2 ratio over targets where both learn: -2.13 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 11; clearly worse: 0; of 12. Largest compute used: 6.5e-01 of a GD run.

