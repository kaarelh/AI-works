## hyb_portfolio on the dlheld2 suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| thr20 | 116 | 593 | -2.35 | 0.17 / 0.06 / 0.02 / 0.01 ; 0.19 / 0.12 / 0.06 / 0.02 | 3.8e-01 |
| maj21 | 123 | 413 | -1.75 | 0.18 / 0.04 / 0.00 / 0.00 ; 0.20 / 0.12 / 0.02 / 0.00 | 1.9e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 0 of 22. Of these, by more than 2 standard errors of the seed-to-seed spread: 0.

Mean log2 ratio over targets where both learn: -2.05 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 2; clearly worse: 0; of 2. Largest compute used: 3.8e-01 of a GD run.

