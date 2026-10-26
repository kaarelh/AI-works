## hyb_union-perm on the dlheld3 suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| cnf3 | 276 | 489 | -0.82 | 0.27 / 0.11 / 0.00 / 0.00 ; 0.28 / 0.17 / 0.02 / 0.00 | 2.1e-01 |
| sym9 | 3151 | 787 | +2.00 | 0.51 / 0.44 / 0.32 / 0.02 ; 0.47 / 0.33 / 0.04 / 0.00 | 3.4e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 7 of 22 (sym9@64: 0.51 vs 0.47; sym9@128: 0.53 vs 0.43; sym9@256: 0.44 vs 0.33; sym9@512: 0.39 vs 0.20; sym9@1024: 0.32 vs 0.04; sym9@2048: 0.23 vs 0.00; sym9@4096: 0.02 vs 0.00). Of these, by more than 2 standard errors of the seed-to-seed spread: 6 (sym9@64, sym9@128, sym9@256, sym9@512, sym9@1024, sym9@2048).

Mean log2 ratio over targets where both learn: +0.59 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 1; clearly worse: 1; of 2. Largest compute used: 3.4e-01 of a GD run.

