## hyb_portfolio on the dlheld3 suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| dlist8 | 26 | 104 | -2.01 | 0.08 / 0.01 / 0.00 / 0.00 ; 0.16 / 0.05 / 0.01 / 0.00 | 2.9e-01 |
| thrint | 151 | 546 | -1.85 | 0.16 / 0.04 / 0.00 / 0.00 ; 0.21 / 0.13 / 0.05 / 0.00 | 2.6e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 1 of 22 (thrint@16: 0.42 vs 0.39). Of these, by more than 2 standard errors of the seed-to-seed spread: 0.

Mean log2 ratio over targets where both learn: -1.93 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 2; clearly worse: 0; of 2. Largest compute used: 2.9e-01 of a GD run.

