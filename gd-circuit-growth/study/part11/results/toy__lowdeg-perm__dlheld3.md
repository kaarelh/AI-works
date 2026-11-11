## lowdeg-perm on the dlheld3 suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| cnf3 | 600 | 489 | +0.30 | 0.34 / 0.27 / 0.00 / 0.00 ; 0.28 / 0.17 / 0.02 / 0.00 | 8.9e-02 |
| sym9 | 3267 | 787 | +2.05 | 0.50 / 0.50 / 0.35 / 0.04 ; 0.47 / 0.33 / 0.04 / 0.00 | 8.9e-02 |
| dlist8 | 29 | 104 | -1.84 | 0.08 / 0.08 / 0.03 / 0.01 ; 0.16 / 0.05 / 0.01 / 0.00 | 8.9e-02 |
| thrint | 659 | 546 | +0.27 | 0.24 / 0.16 / 0.07 / 0.05 ; 0.21 / 0.13 / 0.05 / 0.00 | 8.9e-02 |
| par3or | 177 | 1050 | -2.57 | 0.12 / 0.08 / 0.00 / 0.00 ; 0.39 / 0.37 / 0.10 / 0.00 | 8.9e-02 |
| poly4 | 195 | 10199 | -5.71 | 0.34 / 0.00 / 0.00 / 0.00 ; 0.49 / 0.43 / 0.36 / 0.25 | 8.9e-02 |
| mixmaj | 289 | 507 | -0.81 | 0.29 / 0.12 / 0.00 / 0.00 ; 0.36 / 0.22 / 0.02 / 0.00 | 8.9e-02 |
| mux11 | 1486 | 1527 | -0.04 | 0.50 / 0.45 / 0.21 / 0.00 ; 0.43 / 0.34 / 0.19 / 0.00 | 8.9e-02 |
| h3rf0 | 16 | 109 | -2.76 | 0.07 / 0.07 / 0.05 / 0.00 ; 0.16 / 0.07 / 0.06 / 0.02 | 8.9e-02 |
| h3rf1 | 31 | 123 | -2.00 | 0.09 / 0.09 / 0.05 / 0.00 ; 0.16 / 0.09 / 0.05 / 0.00 | 8.9e-02 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 35 of 110 (cnf3@16: 0.45 vs 0.39; cnf3@64: 0.34 vs 0.28; cnf3@128: 0.34 vs 0.22; cnf3@256: 0.27 vs 0.17; cnf3@512: 0.13 vs 0.09; sym9@64: 0.50 vs 0.47; sym9@128: 0.50 vs 0.43; sym9@256: 0.50 vs 0.33; sym9@512: 0.47 vs 0.20; sym9@1024: 0.35 vs 0.04; sym9@2048: 0.23 vs 0.00; sym9@4096: 0.04 vs 0.00; sym9@8192: 0.02 vs 0.00; dlist8@256: 0.08 vs 0.05; dlist8@512: 0.06 vs 0.03; thrint@16: 0.51 vs 0.39; thrint@32: 0.51 vs 0.31; thrint@64: 0.24 vs 0.21; thrint@128: 0.18 vs 0.15; thrint@256: 0.16 vs 0.13; thrint@1024: 0.07 vs 0.05; thrint@2048: 0.08 vs 0.00; thrint@4096: 0.05 vs 0.00; thrint@8192: 0.05 vs 0.00; thrint@16384: 0.05 vs 0.00; par3or@16: 0.55 vs 0.44; mixmaj@16: 0.50 vs 0.44; mixmaj@32: 0.50 vs 0.41; mux11@16: 0.49 vs 0.45; mux11@32: 0.50 vs 0.44; mux11@64: 0.50 vs 0.43; mux11@128: 0.50 vs 0.40; mux11@256: 0.45 vs 0.34; mux11@512: 0.37 vs 0.28; h3rf1@2048: 0.03 vs 0.01). Of these, by more than 2 standard errors of the seed-to-seed spread: 29 (cnf3@64, cnf3@128, cnf3@256, cnf3@512, sym9@64, sym9@128, sym9@256, sym9@512, sym9@1024, sym9@2048, sym9@4096, sym9@8192, dlist8@256, dlist8@512, thrint@16, thrint@32, thrint@256, thrint@2048, thrint@4096, thrint@8192, thrint@16384, mixmaj@16, mixmaj@32, mux11@16, mux11@32, mux11@64, mux11@128, mux11@256, mux11@512).

Mean log2 ratio over targets where both learn: -1.31 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 6; clearly worse: 3; of 10. Largest compute used: 8.9e-02 of a GD run.

