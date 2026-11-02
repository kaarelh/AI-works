## lowdeg-perm on the dlsymdev suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| sym7 | 1356 | 670 | +1.02 | 0.47 / 0.40 / 0.15 / 0.00 ; 0.48 / 0.32 / 0.02 / 0.00 | 8.9e-02 |
| ex3of8 | 6509 | 1355 | +2.26 | 0.29 / 0.22 / 0.23 / 0.26 ; 0.29 / 0.27 / 0.17 / 0.00 | 8.9e-02 |
| band11 | never | 3253 | +inf | 0.50 / 0.51 / 0.49 / 0.49 ; 0.50 / 0.50 / 0.47 / 0.01 | 9.2e-02 |
| far9 | 1433 | 392 | +1.87 | 0.18 / 0.18 / 0.15 / 0.00 ; 0.23 / 0.14 / 0.05 / 0.00 | 8.9e-02 |
| ssym9 | 2992 | 821 | +1.87 | 0.49 / 0.50 / 0.36 / 0.05 ; 0.47 / 0.33 / 0.05 / 0.00 | 8.9e-02 |
| symxpar | 806 | 2176 | -1.43 | 0.50 / 0.23 / 0.05 / 0.00 ; 0.49 / 0.41 / 0.28 / 0.00 | 8.9e-02 |
| twosym | 5326 | 3389 | +0.65 | 0.48 / 0.51 / 0.49 / 0.16 ; 0.49 / 0.49 / 0.45 / 0.01 | 8.9e-02 |
| thrsum | 406 | 515 | -0.34 | 0.11 / 0.11 / 0.09 / 0.02 ; 0.42 / 0.19 / 0.05 / 0.00 | 8.9e-02 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 30 of 88 (sym7@128: 0.49 vs 0.43; sym7@256: 0.40 vs 0.32; sym7@512: 0.33 vs 0.15; sym7@1024: 0.15 vs 0.02; ex3of8@1024: 0.23 vs 0.17; ex3of8@2048: 0.25 vs 0.00; ex3of8@4096: 0.26 vs 0.00; ex3of8@8192: 0.02 vs 0.00; band11@1024: 0.49 vs 0.47; band11@2048: 0.49 vs 0.28; band11@4096: 0.49 vs 0.01; band11@8192: 0.39 vs 0.00; band11@16384: 0.24 vs 0.00; far9@32: 0.28 vs 0.23; far9@256: 0.18 vs 0.14; far9@512: 0.18 vs 0.08; far9@1024: 0.15 vs 0.05; ssym9@128: 0.49 vs 0.44; ssym9@256: 0.50 vs 0.33; ssym9@512: 0.46 vs 0.20; ssym9@1024: 0.36 vs 0.05; ssym9@2048: 0.16 vs 0.00; ssym9@4096: 0.05 vs 0.00; twosym@512: 0.51 vs 0.48; twosym@1024: 0.49 vs 0.45; twosym@2048: 0.44 vs 0.35; twosym@4096: 0.16 vs 0.01; thrsum@16: 0.51 vs 0.45; thrsum@1024: 0.09 vs 0.05; thrsum@2048: 0.05 vs 0.01). Of these, by more than 2 standard errors of the seed-to-seed spread: 25 (sym7@128, sym7@256, sym7@512, sym7@1024, ex3of8@2048, ex3of8@4096, ex3of8@8192, band11@1024, band11@4096, band11@8192, band11@16384, far9@256, far9@512, far9@1024, ssym9@128, ssym9@256, ssym9@512, ssym9@1024, ssym9@2048, ssym9@4096, twosym@2048, twosym@4096, thrsum@16, thrsum@1024, thrsum@2048).

Mean log2 ratio over targets where both learn: +0.84 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 2; clearly worse: 6; of 8. Largest compute used: 9.2e-02 of a GD run.

