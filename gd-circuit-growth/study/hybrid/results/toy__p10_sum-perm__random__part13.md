## p10_sum-perm on the random suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| rf12 | 87 | 963 | -3.46 | 0.18 / 0.00 / 0.00 / 0.00 ; 0.26 / 0.21 / 0.09 / 0.00 | 2.0e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 1 of 11 (rf12@16: 0.33 vs 0.29). Of these, by more than 2 standard errors of the seed-to-seed spread: 0.

Mean log2 ratio over targets where both learn: -3.46 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 1; clearly worse: 0; of 1. Largest compute used: 2.0e-01 of a GD run.

