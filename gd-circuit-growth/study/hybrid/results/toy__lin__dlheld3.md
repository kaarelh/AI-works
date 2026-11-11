## lin on the dlheld3 suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| cnf3 | never | 489 | +inf | 0.28 / 0.22 / 0.20 / 0.19 ; 0.28 / 0.17 / 0.02 / 0.00 | 7.3e-02 |
| sym9 | never | 787 | +inf | 0.49 / 0.50 / 0.50 / 0.49 ; 0.47 / 0.33 / 0.04 / 0.00 | 7.3e-02 |
| dlist8 | 91 | 104 | -0.19 | 0.12 / 0.03 / 0.01 / 0.00 ; 0.16 / 0.05 / 0.01 / 0.00 | 7.3e-02 |
| thrint | 137 | 546 | -2.00 | 0.17 / 0.01 / 0.00 / 0.00 ; 0.21 / 0.13 / 0.05 / 0.00 | 7.3e-02 |
| par3or | never | 1050 | +inf | 0.38 / 0.36 / 0.37 / 0.37 ; 0.39 / 0.37 / 0.10 / 0.00 | 7.3e-02 |
| poly4 | never | 10199 | +inf | 0.51 / 0.50 / 0.50 / 0.50 ; 0.49 / 0.43 / 0.36 / 0.25 | 7.3e-02 |
| mixmaj | never | 507 | +inf | 0.40 / 0.34 / 0.31 / 0.31 ; 0.36 / 0.22 / 0.02 / 0.00 | 7.3e-02 |
| mux11 | never | 1527 | +inf | 0.46 / 0.41 / 0.37 / 0.36 ; 0.43 / 0.34 / 0.19 / 0.00 | 7.3e-02 |
| h3rf0 | 112 | 109 | +0.05 | 0.17 / 0.07 / 0.07 / 0.07 ; 0.16 / 0.07 / 0.06 / 0.02 | 7.3e-02 |
| h3rf1 | 101 | 123 | -0.29 | 0.12 / 0.09 / 0.08 / 0.07 ; 0.16 / 0.09 / 0.05 / 0.00 | 7.3e-02 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 58 of 110 (cnf3@128: 0.25 vs 0.22; cnf3@256: 0.22 vs 0.17; cnf3@512: 0.20 vs 0.09; cnf3@1024: 0.20 vs 0.02; cnf3@2048: 0.19 vs 0.00; cnf3@4096: 0.19 vs 0.00; cnf3@8192: 0.19 vs 0.00; cnf3@16384: 0.19 vs 0.00; sym9@64: 0.49 vs 0.47; sym9@128: 0.50 vs 0.43; sym9@256: 0.50 vs 0.33; sym9@512: 0.50 vs 0.20; sym9@1024: 0.50 vs 0.04; sym9@2048: 0.50 vs 0.00; sym9@4096: 0.49 vs 0.00; sym9@8192: 0.49 vs 0.00; sym9@16384: 0.49 vs 0.00; par3or@512: 0.36 vs 0.34; par3or@1024: 0.37 vs 0.10; par3or@2048: 0.37 vs 0.00; par3or@4096: 0.37 vs 0.00; par3or@8192: 0.37 vs 0.00; par3or@16384: 0.37 vs 0.00; poly4@128: 0.50 vs 0.47; poly4@256: 0.50 vs 0.43; poly4@512: 0.50 vs 0.40; poly4@1024: 0.50 vs 0.36; poly4@2048: 0.49 vs 0.31; poly4@4096: 0.50 vs 0.25; poly4@8192: 0.51 vs 0.15; poly4@16384: 0.50 vs 0.00; mixmaj@16: 0.48 vs 0.44; mixmaj@64: 0.40 vs 0.36; mixmaj@128: 0.35 vs 0.31; mixmaj@256: 0.34 vs 0.22; mixmaj@512: 0.32 vs 0.10; mixmaj@1024: 0.31 vs 0.02; mixmaj@2048: 0.31 vs 0.00; mixmaj@4096: 0.31 vs 0.00; mixmaj@8192: 0.31 vs 0.00; mixmaj@16384: 0.31 vs 0.00; mux11@64: 0.46 vs 0.43; mux11@128: 0.43 vs 0.40; mux11@256: 0.41 vs 0.34; mux11@512: 0.38 vs 0.28; mux11@1024: 0.37 vs 0.19; mux11@2048: 0.36 vs 0.03; mux11@4096: 0.36 vs 0.00; mux11@8192: 0.36 vs 0.00; mux11@16384: 0.36 vs 0.00; h3rf0@4096: 0.07 vs 0.02; h3rf0@8192: 0.07 vs 0.00; h3rf0@16384: 0.07 vs 0.00; h3rf1@1024: 0.08 vs 0.05; h3rf1@2048: 0.07 vs 0.01; h3rf1@4096: 0.07 vs 0.00; h3rf1@8192: 0.07 vs 0.00; h3rf1@16384: 0.08 vs 0.00). Of these, by more than 2 standard errors of the seed-to-seed spread: 55 (cnf3@128, cnf3@256, cnf3@512, cnf3@1024, cnf3@2048, cnf3@4096, cnf3@8192, cnf3@16384, sym9@64, sym9@128, sym9@256, sym9@512, sym9@1024, sym9@2048, sym9@4096, sym9@8192, sym9@16384, par3or@512, par3or@1024, par3or@2048, par3or@4096, par3or@8192, par3or@16384, poly4@128, poly4@256, poly4@512, poly4@1024, poly4@2048, poly4@4096, poly4@8192, poly4@16384, mixmaj@128, mixmaj@256, mixmaj@512, mixmaj@1024, mixmaj@2048, mixmaj@4096, mixmaj@8192, mixmaj@16384, mux11@64, mux11@256, mux11@512, mux11@1024, mux11@2048, mux11@4096, mux11@8192, mux11@16384, h3rf0@4096, h3rf0@8192, h3rf0@16384, h3rf1@1024, h3rf1@2048, h3rf1@4096, h3rf1@8192, h3rf1@16384).

Mean log2 ratio over targets where both learn: -0.61 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 2; clearly worse: 6; of 10. Largest compute used: 7.3e-02 of a GD run.

