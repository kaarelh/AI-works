## dfg13-core-perm on the dlheld4 suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| ssym8 | 100 | 1160 | -3.53 | 0.28 / 0.00 / 0.00 / 0.00 ; 0.36 / 0.33 / 0.12 / 0.00 | 7.4e-03 |
| symxor | 461 | 1706 | -1.89 | 0.50 / 0.42 / 0.00 / 0.00 ; 0.50 / 0.49 / 0.38 / 0.00 | 1.8e-02 |
| symand | 100 | 498 | -2.31 | 0.28 / 0.00 / 0.00 / 0.00 ; 0.31 / 0.19 / 0.04 / 0.00 | 7.9e-03 |
| sumpar | 146 | 3487 | -4.58 | 0.50 / 0.06 / 0.00 / 0.00 ; 0.38 / 0.31 / 0.25 / 0.07 | 1.9e-02 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 4 of 44 (symand@16: 0.58 vs 0.42; sumpar@16: 0.50 vs 0.43; sumpar@32: 0.50 vs 0.42; sumpar@64: 0.50 vs 0.38). Of these, by more than 2 standard errors of the seed-to-seed spread: 2 (symand@16, sumpar@64).

Mean log2 ratio over targets where both learn: -3.08 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 4; clearly worse: 0; of 4. Largest compute used: 1.9e-02 of a GD run.

