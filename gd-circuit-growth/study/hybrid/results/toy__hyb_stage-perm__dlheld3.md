## hyb_stage-perm on the dlheld3 suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| cnf3 | 119 | 489 | -2.04 | 0.22 / 0.00 / 0.00 / 0.00 ; 0.28 / 0.17 / 0.02 / 0.00 | 8.5e-02 |
| sym9 | 591 | 787 | -0.41 | 0.49 / 0.41 / 0.05 / 0.00 ; 0.47 / 0.33 / 0.04 / 0.00 | 7.4e-01 |
| dlist8 | 22 | 104 | -2.25 | 0.09 / 0.01 / 0.00 / 0.00 ; 0.16 / 0.05 / 0.01 / 0.00 | 1.8e-01 |
| thrint | 146 | 546 | -1.90 | 0.16 / 0.04 / 0.00 / 0.00 ; 0.21 / 0.13 / 0.05 / 0.00 | 1.7e-01 |
| par3or | 57 | 1050 | -4.19 | 0.05 / 0.00 / 0.00 / 0.00 ; 0.39 / 0.37 / 0.10 / 0.00 | 7.6e-02 |
| poly4 | 171 | 10199 | -5.89 | 0.43 / 0.00 / 0.00 / 0.00 ; 0.49 / 0.43 / 0.36 / 0.25 | 7.5e-02 |
| mixmaj | 95 | 507 | -2.42 | 0.20 / 0.00 / 0.00 / 0.00 ; 0.36 / 0.22 / 0.02 / 0.00 | 8.2e-02 |
| mux11 | 605 | 1527 | -1.33 | 0.47 / 0.32 / 0.00 / 0.00 ; 0.43 / 0.34 / 0.19 / 0.00 | 1.3e-01 |
| h3rf0 | 34 | 109 | -1.69 | 0.08 / 0.07 / 0.00 / 0.00 ; 0.16 / 0.07 / 0.06 / 0.02 | 7.8e-02 |
| h3rf1 | 60 | 123 | -1.03 | 0.10 / 0.06 / 0.00 / 0.00 ; 0.16 / 0.09 / 0.05 / 0.00 | 9.7e-02 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 7 of 110 (sym9@64: 0.49 vs 0.47; sym9@128: 0.48 vs 0.43; sym9@256: 0.41 vs 0.33; thrint@16: 0.41 vs 0.39; par3or@16: 0.46 vs 0.44; mux11@64: 0.47 vs 0.43; mux11@128: 0.42 vs 0.40). Of these, by more than 2 standard errors of the seed-to-seed spread: 3 (sym9@64, sym9@128, mux11@64).

Mean log2 ratio over targets where both learn: -2.32 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 10; clearly worse: 0; of 10. Largest compute used: 7.4e-01 of a GD run.

