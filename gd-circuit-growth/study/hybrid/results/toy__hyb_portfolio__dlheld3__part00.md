## hyb_portfolio on the dlheld3 suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| cnf3 | 133 | 489 | -1.88 | 0.22 / 0.01 / 0.00 / 0.00 ; 0.28 / 0.17 / 0.02 / 0.00 | 2.0e-01 |
| sym9 | 1225 | 787 | +0.64 | 0.49 / 0.39 / 0.13 / 0.00 ; 0.47 / 0.33 / 0.04 / 0.00 | 6.6e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 3 of 22 (sym9@128: 0.46 vs 0.43; sym9@256: 0.39 vs 0.33; sym9@1024: 0.13 vs 0.04). Of these, by more than 2 standard errors of the seed-to-seed spread: 1 (sym9@1024).

Mean log2 ratio over targets where both learn: -0.62 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 1; clearly worse: 1; of 2. Largest compute used: 6.6e-01 of a GD run.

