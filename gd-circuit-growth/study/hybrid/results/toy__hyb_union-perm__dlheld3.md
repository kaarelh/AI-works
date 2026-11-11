## hyb_union-perm on the dlheld3 suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| cnf3 | 276 | 489 | -0.82 | 0.27 / 0.11 / 0.00 / 0.00 ; 0.28 / 0.17 / 0.02 / 0.00 | 2.1e-01 |
| sym9 | 3151 | 787 | +2.00 | 0.51 / 0.44 / 0.32 / 0.02 ; 0.47 / 0.33 / 0.04 / 0.00 | 3.4e-01 |
| dlist8 | 72 | 104 | -0.54 | 0.10 / 0.03 / 0.00 / 0.00 ; 0.16 / 0.05 / 0.01 / 0.00 | 2.2e-01 |
| thrint | 132 | 546 | -2.05 | 0.17 / 0.04 / 0.00 / 0.00 ; 0.21 / 0.13 / 0.05 / 0.00 | 2.1e-01 |
| par3or | 75 | 1050 | -3.80 | 0.12 / 0.00 / 0.00 / 0.00 ; 0.39 / 0.37 / 0.10 / 0.00 | 2.2e-01 |
| poly4 | 194 | 10199 | -5.72 | 0.42 / 0.00 / 0.00 / 0.00 ; 0.49 / 0.43 / 0.36 / 0.25 | 2.1e-01 |
| mixmaj | 198 | 507 | -1.35 | 0.22 / 0.08 / 0.00 / 0.00 ; 0.36 / 0.22 / 0.02 / 0.00 | 2.3e-01 |
| mux11 | 776 | 1527 | -0.98 | 0.47 / 0.32 / 0.01 / 0.00 ; 0.43 / 0.34 / 0.19 / 0.00 | 2.4e-01 |
| h3rf0 | 83 | 109 | -0.39 | 0.11 / 0.06 / 0.00 / 0.00 ; 0.16 / 0.07 / 0.06 / 0.02 | 2.1e-01 |
| h3rf1 | 80 | 123 | -0.61 | 0.11 / 0.05 / 0.00 / 0.00 ; 0.16 / 0.09 / 0.05 / 0.00 | 2.2e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 15 of 110 (sym9@64: 0.51 vs 0.47; sym9@128: 0.53 vs 0.43; sym9@256: 0.44 vs 0.33; sym9@512: 0.39 vs 0.20; sym9@1024: 0.32 vs 0.04; sym9@2048: 0.23 vs 0.00; sym9@4096: 0.02 vs 0.00; thrint@16: 0.46 vs 0.39; par3or@16: 0.55 vs 0.44; mixmaj@16: 0.52 vs 0.44; mixmaj@32: 0.46 vs 0.41; mux11@32: 0.47 vs 0.44; mux11@64: 0.47 vs 0.43; mux11@128: 0.42 vs 0.40; h3rf1@16: 0.43 vs 0.36). Of these, by more than 2 standard errors of the seed-to-seed spread: 9 (sym9@64, sym9@128, sym9@256, sym9@512, sym9@1024, sym9@2048, mixmaj@16, mixmaj@32, mux11@64).

Mean log2 ratio over targets where both learn: -1.43 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 9; clearly worse: 1; of 10. Largest compute used: 3.4e-01 of a GD run.

