## p10_sum-perm on the dlheld2 suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| thr20 | 124 | 593 | -2.26 | 0.17 / 0.06 / 0.02 / 0.01 ; 0.19 / 0.12 / 0.06 / 0.02 | 5.6e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 1 of 11 (thr20@16: 0.33 vs 0.31). Of these, by more than 2 standard errors of the seed-to-seed spread: 0.

Mean log2 ratio over targets where both learn: -2.26 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 1; clearly worse: 0; of 1. Largest compute used: 5.6e-01 of a GD run.

