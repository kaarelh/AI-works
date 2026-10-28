## p10_sum-perm on the dlheld suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| majxor | 224 | 1313 | -2.55 | 0.47 / 0.01 / 0.00 / 0.00 ; 0.47 / 0.36 / 0.16 / 0.00 | 4.1e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 1 of 11 (majxor@128: 0.48 vs 0.44). Of these, by more than 2 standard errors of the seed-to-seed spread: 1 (majxor@128).

Mean log2 ratio over targets where both learn: -2.55 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 1; clearly worse: 0; of 1. Largest compute used: 4.1e-01 of a GD run.

