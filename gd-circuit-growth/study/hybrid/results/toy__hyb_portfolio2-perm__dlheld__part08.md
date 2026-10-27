## hyb_portfolio2-perm on the dlheld suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| inter2 | 366 | 859 | -1.23 | 0.19 / 0.12 / 0.04 / 0.00 ; 0.20 / 0.14 / 0.10 / 0.02 | 7.5e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 2 of 11 (inter2@16: 0.34 vs 0.30; inter2@32: 0.31 vs 0.27). Of these, by more than 2 standard errors of the seed-to-seed spread: 0.

Mean log2 ratio over targets where both learn: -1.23 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 1; clearly worse: 0; of 1. Largest compute used: 7.5e-01 of a GD run.

