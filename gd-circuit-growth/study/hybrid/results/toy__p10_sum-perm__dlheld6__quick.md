## p10_sum-perm on the dlheld6 suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| h6_10 | 171 | 1414 | -3.05 | 0.32 / 0.01 / 0.00 / 0.00 ; 0.39 / 0.34 / 0.18 / 0.00 | 8.4e-02 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 0 of 4. Of these, by more than 2 standard errors of the seed-to-seed spread: 0.

Mean log2 ratio over targets where both learn: -3.05 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 1; clearly worse: 0; of 1. Largest compute used: 8.4e-02 of a GD run.

