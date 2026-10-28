## p10_sum-perm on the dlheld3 suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| cnf3 | 126 | 489 | -1.95 | 0.23 / 0.00 / 0.00 / 0.00 ; 0.28 / 0.17 / 0.02 / 0.00 | 3.5e-01 |
| sym9 | 111 | 787 | -2.82 | 0.49 / 0.00 / 0.00 / 0.00 ; 0.47 / 0.33 / 0.04 / 0.00 | 2.3e-01 |
| dlist8 | 24 | 104 | -2.12 | 0.09 / 0.01 / 0.00 / 0.00 ; 0.16 / 0.05 / 0.01 / 0.00 | 3.9e-01 |
| thrint | 139 | 546 | -1.97 | 0.16 / 0.04 / 0.00 / 0.00 ; 0.21 / 0.13 / 0.05 / 0.00 | 2.1e-01 |
| par3or | 63 | 1050 | -4.07 | 0.09 / 0.00 / 0.00 / 0.00 ; 0.39 / 0.37 / 0.10 / 0.00 | 2.0e-01 |
| poly4 | 177 | 10199 | -5.85 | 0.36 / 0.00 / 0.00 / 0.00 ; 0.49 / 0.43 / 0.36 / 0.25 | 2.0e-01 |
| mixmaj | 96 | 507 | -2.40 | 0.16 / 0.00 / 0.00 / 0.00 ; 0.36 / 0.22 / 0.02 / 0.00 | 2.0e-01 |
| mux11 | 466 | 1527 | -1.71 | 0.44 / 0.27 / 0.00 / 0.00 ; 0.43 / 0.34 / 0.19 / 0.00 | 2.2e-01 |
| h3rf0 | 46 | 109 | -1.23 | 0.08 / 0.05 / 0.00 / 0.00 ; 0.16 / 0.07 / 0.06 / 0.02 | 2.0e-01 |
| h3rf1 | 59 | 123 | -1.06 | 0.10 / 0.02 / 0.00 / 0.00 ; 0.16 / 0.09 / 0.05 / 0.00 | 2.2e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 1 of 110 (thrint@16: 0.42 vs 0.39). Of these, by more than 2 standard errors of the seed-to-seed spread: 0.

Mean log2 ratio over targets where both learn: -2.52 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 10; clearly worse: 0; of 10. Largest compute used: 3.9e-01 of a GD run.

