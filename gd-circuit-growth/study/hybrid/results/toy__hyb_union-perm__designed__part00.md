## hyb_union-perm on the designed suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| dict | 24 | 47 | -0.95 | 0.00 / 0.00 / 0.00 / 0.00 ; 0.04 / 0.00 / 0.00 / 0.00 | 2.1e-01 |
| and3 | 52 | 94 | -0.86 | 0.09 / 0.00 / 0.00 / 0.00 ; 0.12 / 0.03 / 0.00 / 0.00 | 2.1e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 0 of 22. Of these, by more than 2 standard errors of the seed-to-seed spread: 0.

Mean log2 ratio over targets where both learn: -0.90 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 2; clearly worse: 0; of 2. Largest compute used: 2.1e-01 of a GD run.

