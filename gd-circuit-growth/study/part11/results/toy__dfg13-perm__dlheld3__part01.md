## dfg13-perm on the dlheld3 suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| cnf3 | 189 | 489 | -1.37 | 0.29 / 0.01 / 0.00 / 0.00 ; 0.28 / 0.17 / 0.02 / 0.00 | 2.1e-01 |
| sym9 | 111 | 787 | -2.82 | 0.50 / 0.00 / 0.00 / 0.00 ; 0.47 / 0.33 / 0.04 / 0.00 | 1.6e-01 |
| dlist8 | 39 | 104 | -1.43 | 0.09 / 0.03 / 0.00 / 0.00 ; 0.16 / 0.05 / 0.01 / 0.00 | 2.8e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 1 of 33 (sym9@64: 0.50 vs 0.47). Of these, by more than 2 standard errors of the seed-to-seed spread: 1 (sym9@64).

Mean log2 ratio over targets where both learn: -1.87 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 3; clearly worse: 0; of 3. Largest compute used: 2.8e-01 of a GD run.

