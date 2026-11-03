## dfg13-core-perm on the dlheld3 suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| cnf3 | 164 | 489 | -1.57 | 0.34 / 0.03 / 0.00 / 0.00 ; 0.28 / 0.17 / 0.02 / 0.00 | 1.2e-02 |
| sym9 | 111 | 787 | -2.82 | 0.49 / 0.00 / 0.00 / 0.00 ; 0.47 / 0.33 / 0.04 / 0.00 | 7.4e-03 |
| dlist8 | 30 | 104 | -1.79 | 0.08 / 0.01 / 0.00 / 0.00 ; 0.16 / 0.05 / 0.01 / 0.00 | 2.0e-02 |
| thrint | 287 | 546 | -0.93 | 0.19 / 0.12 / 0.00 / 0.00 ; 0.21 / 0.13 / 0.05 / 0.00 | 2.0e-02 |
| par3or | 60 | 1050 | -4.13 | 0.06 / 0.00 / 0.00 / 0.00 ; 0.39 / 0.37 / 0.10 / 0.00 | 7.1e-03 |
| poly4 | 3127 | 10199 | -1.71 | 0.31 / 0.26 / 0.26 / 0.00 ; 0.49 / 0.43 / 0.36 / 0.25 | 1.6e-02 |
| mixmaj | 89 | 507 | -2.52 | 0.19 / 0.00 / 0.00 / 0.00 ; 0.36 / 0.22 / 0.02 / 0.00 | 9.1e-03 |
| mux11 | 850 | 1527 | -0.84 | 0.50 / 0.50 / 0.00 / 0.00 ; 0.43 / 0.34 / 0.19 / 0.00 | 1.7e-02 |
| h3rf0 | 30 | 109 | -1.84 | 0.07 / 0.10 / 0.00 / 0.00 ; 0.16 / 0.07 / 0.06 / 0.02 | 2.1e-02 |
| h3rf1 | 31 | 123 | -2.00 | 0.09 / 0.03 / 0.00 / 0.00 ; 0.16 / 0.09 / 0.05 / 0.00 | 1.7e-02 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 16 of 110 (cnf3@64: 0.34 vs 0.28; thrint@16: 0.48 vs 0.39; thrint@32: 0.50 vs 0.31; par3or@16: 0.50 vs 0.44; par3or@32: 0.50 vs 0.43; poly4@16384: 0.13 vs 0.00; mixmaj@16: 0.50 vs 0.44; mixmaj@32: 0.50 vs 0.41; mux11@16: 0.49 vs 0.45; mux11@32: 0.50 vs 0.44; mux11@64: 0.50 vs 0.43; mux11@128: 0.50 vs 0.40; mux11@256: 0.50 vs 0.34; mux11@512: 0.37 vs 0.28; h3rf0@16: 0.44 vs 0.36; h3rf0@256: 0.10 vs 0.07). Of these, by more than 2 standard errors of the seed-to-seed spread: 12 (cnf3@64, thrint@16, thrint@32, mixmaj@16, mixmaj@32, mux11@16, mux11@32, mux11@64, mux11@128, mux11@256, mux11@512, h3rf0@16).

Mean log2 ratio over targets where both learn: -2.01 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 10; clearly worse: 0; of 10. Largest compute used: 2.1e-02 of a GD run.

