## hyb_portfolio2-perm on the dlheld5 suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| h5s6 | 573 | 6227 | -3.44 | 0.37 / 0.36 / 0.00 / 0.00 ; 0.44 / 0.44 / 0.42 / 0.24 | 6.4e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 0 of 11. Of these, by more than 2 standard errors of the seed-to-seed spread: 0.

Mean log2 ratio over targets where both learn: -3.44 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 1; clearly worse: 0; of 1. Largest compute used: 6.4e-01 of a GD run.

