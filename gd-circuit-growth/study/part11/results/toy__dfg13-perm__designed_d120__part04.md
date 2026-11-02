## dfg13-perm on the designed_d120 suite (d = 120)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| par3 | 56 | 14029 | -7.98 | 0.00 / 0.00 / 0.00 / 0.00 ; nan / nan / 0.50 / 0.50 | 1.8e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 0 of 6. Of these, by more than 2 standard errors of the seed-to-seed spread: 0.

Mean log2 ratio over targets where both learn: -7.98 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 1; clearly worse: 0; of 1. Largest compute used: 1.8e-01 of a GD run.

