## hyb_portfolio on the dlheld3 suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| par3or | 60 | 1050 | -4.12 | 0.07 / 0.00 / 0.00 / 0.00 ; 0.39 / 0.37 / 0.10 / 0.00 | 1.9e-01 |
| poly4 | 176 | 10199 | -5.86 | 0.38 / 0.00 / 0.00 / 0.00 ; 0.49 / 0.43 / 0.36 / 0.25 | 1.9e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 1 of 22 (par3or@16: 0.49 vs 0.44). Of these, by more than 2 standard errors of the seed-to-seed spread: 0.

Mean log2 ratio over targets where both learn: -4.99 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 2; clearly worse: 0; of 2. Largest compute used: 1.9e-01 of a GD run.

