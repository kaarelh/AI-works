## p10_sum-perm on the dlheld2 suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| dnf4x2 | 112 | 440 | -1.97 | 0.23 / 0.00 / 0.00 / 0.00 ; 0.26 / 0.16 / 0.01 / 0.00 | 3.9e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 1 of 11 (dnf4x2@16: 0.43 vs 0.33). Of these, by more than 2 standard errors of the seed-to-seed spread: 0.

Mean log2 ratio over targets where both learn: -1.97 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 1; clearly worse: 0; of 1. Largest compute used: 3.9e-01 of a GD run.

