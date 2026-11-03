## dfg13-noeig-perm on the dlheld6 suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| h6_04 | 79 | 116 | -0.55 | 0.12 / 0.02 / 0.00 / 0.00 ; 0.16 / 0.05 / 0.01 / 0.00 | 1.5e-01 |
| h6_05 | 39 | 78 | -0.99 | 0.05 / 0.01 / 0.00 / 0.00 ; 0.12 / 0.04 / 0.02 / 0.00 | 2.4e-01 |
| h6_06 | 396 | 3726 | -3.24 | 0.51 / 0.25 / 0.00 / 0.00 ; 0.50 / 0.50 / 0.48 / 0.05 | 1.4e-01 |
| h6_07 | 388 | 3215 | -3.05 | 0.42 / 0.25 / 0.01 / 0.00 ; 0.40 / 0.31 / 0.25 / 0.05 | 2.0e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 1 of 44 (h6_07@16: 0.46 vs 0.44). Of these, by more than 2 standard errors of the seed-to-seed spread: 0.

Mean log2 ratio over targets where both learn: -1.96 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 4; clearly worse: 0; of 4. Largest compute used: 2.4e-01 of a GD run.

