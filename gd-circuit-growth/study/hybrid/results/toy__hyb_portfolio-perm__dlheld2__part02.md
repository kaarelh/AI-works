## hyb_portfolio-perm on the dlheld2 suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| sym8 | 401 | 504 | -0.33 | 0.28 / 0.14 / 0.01 / 0.00 ; 0.36 / 0.23 / 0.05 / 0.00 | 3.0e-01 |
| h2rf0 | 108 | 527 | -2.29 | 0.17 / 0.05 / 0.00 / 0.00 ; 0.38 / 0.24 / 0.02 / 0.00 | 2.1e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 1 of 22 (h2rf0@16: 0.50 vs 0.46). Of these, by more than 2 standard errors of the seed-to-seed spread: 0.

Mean log2 ratio over targets where both learn: -1.31 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 2; clearly worse: 0; of 2. Largest compute used: 3.0e-01 of a GD run.

