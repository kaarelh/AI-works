## hyb_portfolio-perm on the random suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| rf04 | 48 | 342 | -2.82 | 0.00 / 0.00 / 0.00 / 0.00 ; 0.38 / 0.17 / 0.00 / 0.00 | 1.9e-01 |
| rf05 | 76 | 873 | -3.52 | 0.13 / 0.00 / 0.00 / 0.00 ; 0.47 / 0.44 / 0.02 / 0.00 | 1.9e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 0 of 22. Of these, by more than 2 standard errors of the seed-to-seed spread: 0.

Mean log2 ratio over targets where both learn: -3.17 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 2; clearly worse: 0; of 2. Largest compute used: 1.9e-01 of a GD run.

