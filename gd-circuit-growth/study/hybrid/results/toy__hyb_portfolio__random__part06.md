## hyb_portfolio on the random suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| rf12 | 90 | 963 | -3.42 | 0.20 / 0.00 / 0.00 / 0.00 ; 0.26 / 0.21 / 0.09 / 0.00 | 2.0e-01 |
| rf13 | 52 | 401 | -2.95 | 0.00 / 0.00 / 0.00 / 0.00 ; 0.36 / 0.26 / 0.00 / 0.00 | 1.9e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 1 of 22 (rf12@16: 0.34 vs 0.29). Of these, by more than 2 standard errors of the seed-to-seed spread: 0.

Mean log2 ratio over targets where both learn: -3.18 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 2; clearly worse: 0; of 2. Largest compute used: 2.0e-01 of a GD run.

