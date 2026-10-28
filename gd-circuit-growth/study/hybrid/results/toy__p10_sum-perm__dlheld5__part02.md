## p10_sum-perm on the dlheld5 suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| h5s1 | never | never | +nan | 0.50 / 0.50 / 0.50 / 0.49 ; 0.50 / 0.50 / 0.49 / 0.50 | 7.1e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 0 of 11. Of these, by more than 2 standard errors of the seed-to-seed spread: 0.

Mean log2 ratio over targets where both learn: +nan (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 0; clearly worse: 0; of 1. Largest compute used: 7.1e-01 of a GD run.

