## p10_sum-perm on the dlheld suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| majmaj5 | 360 | 2847 | -2.98 | 0.26 / 0.17 / 0.00 / 0.00 ; 0.29 / 0.22 / 0.20 / 0.03 | 5.8e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 2 of 11 (majmaj5@16: 0.47 vs 0.44; majmaj5@32: 0.35 vs 0.32). Of these, by more than 2 standard errors of the seed-to-seed spread: 0.

Mean log2 ratio over targets where both learn: -2.98 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 1; clearly worse: 0; of 1. Largest compute used: 5.8e-01 of a GD run.

