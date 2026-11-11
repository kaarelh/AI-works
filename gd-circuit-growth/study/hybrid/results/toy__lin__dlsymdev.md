## lin on the dlsymdev suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| sym7 | never | 670 | +inf | 0.47 / 0.46 / 0.47 / 0.45 ; 0.48 / 0.32 / 0.02 / 0.00 | 7.3e-02 |
| ex3of8 | never | 1355 | +inf | 0.25 / 0.22 / 0.22 / 0.22 ; 0.29 / 0.27 / 0.17 / 0.00 | 7.3e-02 |
| band11 | never | 3253 | +inf | 0.50 / 0.50 / 0.49 / 0.49 ; 0.50 / 0.50 / 0.47 / 0.01 | 7.3e-02 |
| far9 | never | 392 | +inf | 0.18 / 0.18 / 0.18 / 0.18 ; 0.23 / 0.14 / 0.05 / 0.00 | 7.3e-02 |
| ssym9 | never | 821 | +inf | 0.49 / 0.50 / 0.49 / 0.48 ; 0.47 / 0.33 / 0.05 / 0.00 | 7.3e-02 |
| symxpar | never | 2176 | +inf | 0.51 / 0.50 / 0.50 / 0.50 ; 0.49 / 0.41 / 0.28 / 0.00 | 7.3e-02 |
| twosym | never | 3389 | +inf | 0.49 / 0.51 / 0.49 / 0.47 ; 0.49 / 0.49 / 0.45 / 0.01 | 7.3e-02 |
| thrsum | never | never | +nan | 0.46 / 0.40 / 0.39 / 0.38 ; – | 7.3e-02 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 47 of 77 (sym7@128: 0.46 vs 0.43; sym7@256: 0.46 vs 0.32; sym7@512: 0.47 vs 0.15; sym7@1024: 0.47 vs 0.02; sym7@2048: 0.46 vs 0.00; sym7@4096: 0.45 vs 0.00; sym7@8192: 0.46 vs 0.00; sym7@16384: 0.45 vs 0.00; ex3of8@1024: 0.22 vs 0.17; ex3of8@2048: 0.22 vs 0.00; ex3of8@4096: 0.22 vs 0.00; ex3of8@8192: 0.22 vs 0.00; ex3of8@16384: 0.22 vs 0.00; band11@1024: 0.49 vs 0.47; band11@2048: 0.49 vs 0.28; band11@4096: 0.49 vs 0.01; band11@8192: 0.49 vs 0.00; band11@16384: 0.49 vs 0.00; far9@256: 0.18 vs 0.14; far9@512: 0.18 vs 0.08; far9@1024: 0.18 vs 0.05; far9@2048: 0.18 vs 0.03; far9@4096: 0.18 vs 0.00; far9@8192: 0.18 vs 0.00; far9@16384: 0.18 vs 0.00; ssym9@128: 0.49 vs 0.44; ssym9@256: 0.50 vs 0.33; ssym9@512: 0.50 vs 0.20; ssym9@1024: 0.49 vs 0.05; ssym9@2048: 0.49 vs 0.00; ssym9@4096: 0.48 vs 0.00; ssym9@8192: 0.49 vs 0.00; ssym9@16384: 0.49 vs 0.00; symxpar@128: 0.50 vs 0.46; symxpar@256: 0.50 vs 0.41; symxpar@512: 0.50 vs 0.36; symxpar@1024: 0.50 vs 0.28; symxpar@2048: 0.51 vs 0.11; symxpar@4096: 0.50 vs 0.00; symxpar@8192: 0.49 vs 0.00; symxpar@16384: 0.49 vs 0.00; twosym@512: 0.51 vs 0.48; twosym@1024: 0.49 vs 0.45; twosym@2048: 0.48 vs 0.35; twosym@4096: 0.47 vs 0.01; twosym@8192: 0.48 vs 0.00; twosym@16384: 0.48 vs 0.00). Of these, by more than 2 standard errors of the seed-to-seed spread: 44 (sym7@128, sym7@256, sym7@512, sym7@1024, sym7@2048, sym7@4096, sym7@8192, sym7@16384, ex3of8@2048, ex3of8@4096, ex3of8@8192, ex3of8@16384, band11@1024, band11@4096, band11@8192, band11@16384, far9@256, far9@512, far9@1024, far9@2048, far9@4096, far9@8192, far9@16384, ssym9@128, ssym9@256, ssym9@512, ssym9@1024, ssym9@2048, ssym9@4096, ssym9@8192, ssym9@16384, symxpar@128, symxpar@256, symxpar@512, symxpar@1024, symxpar@2048, symxpar@4096, symxpar@8192, symxpar@16384, twosym@1024, twosym@2048, twosym@4096, twosym@8192, twosym@16384).

Mean log2 ratio over targets where both learn: +nan (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 0; clearly worse: 7; of 8. Largest compute used: 7.3e-02 of a GD run.

