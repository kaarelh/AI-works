## hyb_portfolio-perm on the random suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| rf06 | 16 | 61 | -1.94 | 0.05 / 0.00 / 0.00 / 0.00 ; 0.09 / 0.02 / 0.01 / 0.00 | 2.0e-01 |
| rf07 | 97 | 407 | -2.07 | 0.22 / 0.00 / 0.00 / 0.00 ; 0.38 / 0.17 / 0.00 / 0.00 | 1.9e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 1 of 22 (rf07@16: 0.51 vs 0.45). Of these, by more than 2 standard errors of the seed-to-seed spread: 1 (rf07@16).

Mean log2 ratio over targets where both learn: -2.00 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 2; clearly worse: 0; of 2. Largest compute used: 2.0e-01 of a GD run.

