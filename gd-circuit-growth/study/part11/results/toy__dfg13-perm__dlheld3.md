## dfg13-perm on the dlheld3 suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| cnf3 | 189 | 489 | -1.37 | 0.29 / 0.01 / 0.00 / 0.00 ; 0.28 / 0.17 / 0.02 / 0.00 | 2.1e-01 |
| sym9 | 111 | 787 | -2.82 | 0.50 / 0.00 / 0.00 / 0.00 ; 0.47 / 0.33 / 0.04 / 0.00 | 1.6e-01 |
| dlist8 | 39 | 104 | -1.43 | 0.09 / 0.03 / 0.00 / 0.00 ; 0.16 / 0.05 / 0.01 / 0.00 | 2.8e-01 |
| thrint | 186 | 546 | -1.55 | 0.18 / 0.07 / 0.00 / 0.00 ; 0.21 / 0.13 / 0.05 / 0.00 | 1.5e-01 |
| par3or | 71 | 1050 | -3.89 | 0.12 / 0.01 / 0.00 / 0.00 ; 0.39 / 0.37 / 0.10 / 0.00 | 1.4e-01 |
| poly4 | 176 | 10199 | -5.85 | 0.42 / 0.00 / 0.00 / 0.00 ; 0.49 / 0.43 / 0.36 / 0.25 | 1.4e-01 |
| mixmaj | 114 | 507 | -2.16 | 0.23 / 0.00 / 0.00 / 0.00 ; 0.36 / 0.22 / 0.02 / 0.00 | 1.4e-01 |
| mux11 | 509 | 1527 | -1.59 | 0.44 / 0.40 / 0.00 / 0.00 ; 0.43 / 0.34 / 0.19 / 0.00 | 1.5e-01 |
| h3rf0 | 108 | 109 | -0.01 | 0.12 / 0.06 / 0.00 / 0.00 ; 0.16 / 0.07 / 0.06 / 0.02 | 1.4e-01 |
| h3rf1 | 133 | 123 | +0.12 | 0.11 / 0.03 / 0.00 / 0.00 ; 0.16 / 0.09 / 0.05 / 0.00 | 1.5e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 4 of 110 (sym9@64: 0.50 vs 0.47; par3or@16: 0.47 vs 0.44; mux11@128: 0.43 vs 0.40; mux11@256: 0.40 vs 0.34). Of these, by more than 2 standard errors of the seed-to-seed spread: 2 (sym9@64, mux11@256).

Mean log2 ratio over targets where both learn: -2.05 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 8; clearly worse: 0; of 10. Largest compute used: 2.8e-01 of a GD run.

