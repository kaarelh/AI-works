## dfg13-strict-perm on the dlheld6 suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| h6_04 | 80 | 116 | -0.53 | 0.13 / 0.02 / 0.00 / 0.00 ; 0.16 / 0.05 / 0.01 / 0.00 | 1.5e-01 |
| h6_05 | 48 | 78 | -0.69 | 0.05 / 0.01 / 0.00 / 0.00 ; 0.12 / 0.04 / 0.02 / 0.00 | 2.2e-01 |
| h6_06 | 395 | 3726 | -3.24 | 0.51 / 0.25 / 0.01 / 0.00 ; 0.50 / 0.50 / 0.48 / 0.05 | 1.5e-01 |
| h6_07 | 488 | 3215 | -2.72 | 0.41 / 0.20 / 0.01 / 0.00 ; 0.40 / 0.31 / 0.25 / 0.05 | 1.8e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 1 of 44 (h6_07@16: 0.46 vs 0.44). Of these, by more than 2 standard errors of the seed-to-seed spread: 0.

Mean log2 ratio over targets where both learn: -1.80 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 4; clearly worse: 0; of 4. Largest compute used: 2.2e-01 of a GD run.

