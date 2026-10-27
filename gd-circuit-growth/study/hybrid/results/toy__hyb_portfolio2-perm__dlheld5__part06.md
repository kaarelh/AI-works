## hyb_portfolio2-perm on the dlheld5 suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| h5s5 | 421 | 13832 | -5.04 | 0.42 / 0.35 / 0.00 / 0.00 ; 0.40 / 0.38 / 0.37 / 0.37 | 7.8e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 3 of 11 (h5s5@16: 0.50 vs 0.48; h5s5@32: 0.46 vs 0.43; h5s5@64: 0.42 vs 0.40). Of these, by more than 2 standard errors of the seed-to-seed spread: 1 (h5s5@32).

Mean log2 ratio over targets where both learn: -5.04 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 1; clearly worse: 0; of 1. Largest compute used: 7.8e-01 of a GD run.

