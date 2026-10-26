## abl_dfg-perm on the dlheld3 suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| cnf3 | 213 | 489 | -1.20 | 0.30 / 0.05 / 0.00 / 0.00 ; 0.28 / 0.17 / 0.02 / 0.00 | 1.7e-01 |
| sym9 | 1220 | 787 | +0.63 | 0.49 / 0.38 / 0.13 / 0.00 ; 0.47 / 0.33 / 0.04 / 0.00 | 6.3e-01 |
| dlist8 | 31 | 104 | -1.73 | 0.10 / 0.03 / 0.01 / 0.00 ; 0.16 / 0.05 / 0.01 / 0.00 | 2.6e-01 |
| thrint | 167 | 546 | -1.71 | 0.18 / 0.05 / 0.00 / 0.00 ; 0.21 / 0.13 / 0.05 / 0.00 | 2.3e-01 |
| par3or | 61 | 1050 | -4.11 | 0.08 / 0.00 / 0.00 / 0.00 ; 0.39 / 0.37 / 0.10 / 0.00 | 1.6e-01 |
| poly4 | 177 | 10199 | -5.85 | 0.37 / 0.00 / 0.00 / 0.00 ; 0.49 / 0.43 / 0.36 / 0.25 | 1.6e-01 |
| mixmaj | 109 | 507 | -2.21 | 0.19 / 0.00 / 0.00 / 0.00 ; 0.36 / 0.22 / 0.02 / 0.00 | 1.6e-01 |
| mux11 | 826 | 1527 | -0.89 | 0.47 / 0.39 / 0.00 / 0.00 ; 0.43 / 0.34 / 0.19 / 0.00 | 1.9e-01 |
| h3rf0 | 51 | 109 | -1.08 | 0.09 / 0.02 / 0.00 / 0.00 ; 0.16 / 0.07 / 0.06 / 0.02 | 1.6e-01 |
| h3rf1 | 56 | 123 | -1.14 | 0.09 / 0.03 / 0.00 / 0.00 ; 0.16 / 0.09 / 0.05 / 0.00 | 1.7e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 10 of 110 (sym9@64: 0.49 vs 0.47; sym9@128: 0.50 vs 0.43; sym9@256: 0.38 vs 0.33; sym9@1024: 0.13 vs 0.04; thrint@16: 0.46 vs 0.39; mux11@32: 0.47 vs 0.44; mux11@64: 0.47 vs 0.43; mux11@128: 0.44 vs 0.40; mux11@256: 0.39 vs 0.34; mux11@512: 0.32 vs 0.28). Of these, by more than 2 standard errors of the seed-to-seed spread: 7 (sym9@64, sym9@128, sym9@1024, thrint@16, mux11@128, mux11@256, mux11@512).

Mean log2 ratio over targets where both learn: -1.93 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 9; clearly worse: 1; of 10. Largest compute used: 6.3e-01 of a GD run.

