## hyb_portfolio-perm on the dlheld suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| stair6 | 180 | 1967 | -3.45 | 0.35 / 0.00 / 0.00 / 0.00 ; 0.38 / 0.34 / 0.26 / 0.00 | 2.1e-01 |
| inter2 | 394 | 859 | -1.12 | 0.19 / 0.12 / 0.05 / 0.00 ; 0.20 / 0.14 / 0.10 / 0.02 | 7.2e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 2 of 22 (inter2@16: 0.34 vs 0.30; inter2@32: 0.31 vs 0.27). Of these, by more than 2 standard errors of the seed-to-seed spread: 0.

Mean log2 ratio over targets where both learn: -2.29 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 2; clearly worse: 0; of 2. Largest compute used: 7.2e-01 of a GD run.

