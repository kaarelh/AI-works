## hyb_portfolio-perm on the dlheld suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| majpar5 | 127 | 5229 | -5.37 | 0.42 / 0.03 / 0.00 / 0.00 ; 0.47 / 0.37 / 0.18 / 0.14 | 1.9e-01 |
| hrf0 | 46 | 192 | -2.06 | 0.06 / 0.00 / 0.00 / 0.00 ; 0.15 / 0.09 / 0.06 / 0.00 | 2.0e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 0 of 22. Of these, by more than 2 standard errors of the seed-to-seed spread: 0.

Mean log2 ratio over targets where both learn: -3.72 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 2; clearly worse: 0; of 2. Largest compute used: 2.0e-01 of a GD run.

