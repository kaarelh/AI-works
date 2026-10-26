## hyb_union-perm on the dlheld3 suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| h3rf0 | 83 | 109 | -0.39 | 0.11 / 0.06 / 0.00 / 0.00 ; 0.16 / 0.07 / 0.06 / 0.02 | 2.1e-01 |
| h3rf1 | 80 | 123 | -0.61 | 0.11 / 0.05 / 0.00 / 0.00 ; 0.16 / 0.09 / 0.05 / 0.00 | 2.2e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 1 of 22 (h3rf1@16: 0.43 vs 0.36). Of these, by more than 2 standard errors of the seed-to-seed spread: 0.

Mean log2 ratio over targets where both learn: -0.50 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 2; clearly worse: 0; of 2. Largest compute used: 2.2e-01 of a GD run.

