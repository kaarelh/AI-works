## hyb_portfolio2-perm on the dlheld4 suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| symand | 170 | 498 | -1.55 | 0.28 / 0.00 / 0.00 / 0.00 ; 0.31 / 0.19 / 0.04 / 0.00 | 2.3e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 1 of 11 (symand@16: 0.48 vs 0.42). Of these, by more than 2 standard errors of the seed-to-seed spread: 0.

Mean log2 ratio over targets where both learn: -1.55 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 1; clearly worse: 0; of 1. Largest compute used: 2.3e-01 of a GD run.

