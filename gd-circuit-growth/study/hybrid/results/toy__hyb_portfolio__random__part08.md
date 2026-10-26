## hyb_portfolio on the random suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| rf16 | 38 | 354 | -3.21 | 0.03 / 0.00 / 0.00 / 0.00 ; 0.25 / 0.16 / 0.00 / 0.00 | 1.9e-01 |
| rf17 | 56 | 3049 | -5.77 | 0.00 / 0.00 / 0.00 / 0.00 ; 0.51 / 0.51 / 0.50 / 0.00 | 1.9e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 0 of 22. Of these, by more than 2 standard errors of the seed-to-seed spread: 0.

Mean log2 ratio over targets where both learn: -4.49 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 2; clearly worse: 0; of 2. Largest compute used: 1.9e-01 of a GD run.

