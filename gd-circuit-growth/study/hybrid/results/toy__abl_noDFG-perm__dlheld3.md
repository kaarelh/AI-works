## abl_noDFG-perm on the dlheld3 suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| cnf3 | 130 | 489 | -1.91 | 0.22 / 0.01 / 0.00 / 0.00 ; 0.28 / 0.17 / 0.02 / 0.00 | 3.0e-02 |
| sym9 | 7113 | 787 | +3.18 | 0.49 / 0.44 / 0.35 / 0.16 ; 0.47 / 0.33 / 0.04 / 0.00 | 3.0e-02 |
| dlist8 | 26 | 104 | -1.99 | 0.08 / 0.01 / 0.00 / 0.00 ; 0.16 / 0.05 / 0.01 / 0.00 | 3.0e-02 |
| thrint | 142 | 546 | -1.95 | 0.18 / 0.05 / 0.00 / 0.00 ; 0.21 / 0.13 / 0.05 / 0.00 | 3.0e-02 |
| par3or | 7531 | 1050 | +2.84 | 0.38 / 0.34 / 0.22 / 0.14 ; 0.39 / 0.37 / 0.10 / 0.00 | 3.0e-02 |
| poly4 | never | 10199 | +inf | 0.46 / 0.45 / 0.33 / 0.27 ; 0.49 / 0.43 / 0.36 / 0.25 | 3.0e-02 |
| mixmaj | 341 | 507 | -0.57 | 0.31 / 0.12 / 0.05 / 0.00 ; 0.36 / 0.22 / 0.02 / 0.00 | 3.0e-02 |
| mux11 | 521 | 1527 | -1.55 | 0.44 / 0.27 / 0.00 / 0.00 ; 0.43 / 0.34 / 0.19 / 0.00 | 3.0e-02 |
| h3rf0 | 48 | 109 | -1.17 | 0.08 / 0.07 / 0.05 / 0.03 ; 0.16 / 0.07 / 0.06 / 0.02 | 3.0e-02 |
| h3rf1 | 80 | 123 | -0.61 | 0.11 / 0.05 / 0.02 / 0.00 ; 0.16 / 0.09 / 0.05 / 0.00 | 3.0e-02 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 18 of 110 (sym9@128: 0.46 vs 0.43; sym9@256: 0.44 vs 0.33; sym9@512: 0.39 vs 0.20; sym9@1024: 0.35 vs 0.04; sym9@2048: 0.25 vs 0.00; sym9@4096: 0.16 vs 0.00; sym9@8192: 0.08 vs 0.00; sym9@16384: 0.03 vs 0.00; par3or@1024: 0.22 vs 0.10; par3or@2048: 0.14 vs 0.00; par3or@4096: 0.14 vs 0.00; par3or@8192: 0.09 vs 0.00; par3or@16384: 0.03 vs 0.00; poly4@256: 0.45 vs 0.43; poly4@8192: 0.23 vs 0.15; poly4@16384: 0.23 vs 0.00; mixmaj@1024: 0.05 vs 0.02; h3rf0@8192: 0.03 vs 0.00). Of these, by more than 2 standard errors of the seed-to-seed spread: 13 (sym9@256, sym9@512, sym9@1024, sym9@2048, sym9@4096, sym9@8192, sym9@16384, par3or@2048, par3or@4096, par3or@8192, poly4@8192, poly4@16384, mixmaj@1024).

Mean log2 ratio over targets where both learn: -0.42 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 7; clearly worse: 3; of 10. Largest compute used: 3.0e-02 of a GD run.

