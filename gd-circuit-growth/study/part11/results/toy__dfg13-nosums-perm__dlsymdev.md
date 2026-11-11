## dfg13-nosums-perm on the dlsymdev suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| sym7 | 685 | 670 | +0.03 | 0.47 / 0.23 / 0.00 / 0.00 ; 0.48 / 0.32 / 0.02 / 0.00 | 1.6e-01 |
| ex3of8 | 1337 | 1355 | -0.02 | 0.33 / 0.27 / 0.16 / 0.00 ; 0.29 / 0.27 / 0.17 / 0.00 | 2.8e-01 |
| band11 | never | 3253 | +inf | 0.50 / 0.50 / 0.49 / 0.34 ; 0.50 / 0.50 / 0.47 / 0.01 | 4.9e-01 |
| far9 | 308 | 392 | -0.35 | 0.22 / 0.12 / 0.00 / 0.00 ; 0.23 / 0.14 / 0.05 / 0.00 | 1.4e-01 |
| ssym9 | 1197 | 821 | +0.54 | 0.49 / 0.29 / 0.12 / 0.00 ; 0.47 / 0.33 / 0.05 / 0.00 | 4.0e-01 |
| symxpar | 311 | 2176 | -2.81 | 0.51 / 0.14 / 0.00 / 0.00 ; 0.49 / 0.41 / 0.28 / 0.00 | 1.4e-01 |
| twosym | 3466 | 3389 | +0.03 | 0.50 / 0.51 / 0.50 / 0.00 ; 0.49 / 0.49 / 0.45 / 0.01 | 4.0e-01 |
| thrsum | 71 | 515 | -2.86 | 0.10 / 0.00 / 0.00 / 0.00 ; 0.42 / 0.19 / 0.05 / 0.00 | 1.4e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 22 of 88 (sym7@16: 0.50 vs 0.48; sym7@128: 0.48 vs 0.43; sym7@512: 0.17 vs 0.15; ex3of8@16: 0.32 vs 0.24; ex3of8@32: 0.33 vs 0.28; ex3of8@64: 0.33 vs 0.29; ex3of8@128: 0.29 vs 0.27; ex3of8@512: 0.28 vs 0.24; band11@512: 0.51 vs 0.49; band11@1024: 0.49 vs 0.47; band11@2048: 0.43 vs 0.28; band11@4096: 0.34 vs 0.01; band11@8192: 0.35 vs 0.00; band11@16384: 0.27 vs 0.00; far9@16: 0.37 vs 0.26; far9@32: 0.26 vs 0.23; ssym9@128: 0.50 vs 0.44; ssym9@1024: 0.12 vs 0.05; ssym9@2048: 0.03 vs 0.00; symxpar@64: 0.51 vs 0.49; twosym@1024: 0.50 vs 0.45; twosym@2048: 0.42 vs 0.35). Of these, by more than 2 standard errors of the seed-to-seed spread: 14 (sym7@128, ex3of8@32, ex3of8@128, ex3of8@512, band11@512, band11@1024, band11@4096, band11@8192, band11@16384, far9@16, ssym9@128, ssym9@1024, symxpar@64, twosym@1024).

Mean log2 ratio over targets where both learn: -0.78 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 3; clearly worse: 2; of 8. Largest compute used: 4.9e-01 of a GD run.

