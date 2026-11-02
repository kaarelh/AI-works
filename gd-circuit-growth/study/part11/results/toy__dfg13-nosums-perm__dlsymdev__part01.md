## dfg13-nosums-perm on the dlsymdev suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| sym7 | 685 | 670 | +0.03 | 0.47 / 0.23 / 0.00 / 0.00 ; 0.48 / 0.32 / 0.02 / 0.00 | 1.6e-01 |
| ex3of8 | 1337 | 1355 | -0.02 | 0.33 / 0.27 / 0.16 / 0.00 ; 0.29 / 0.27 / 0.17 / 0.00 | 2.8e-01 |
| band11 | never | 3253 | +inf | 0.50 / 0.50 / 0.49 / 0.34 ; 0.50 / 0.50 / 0.47 / 0.01 | 4.9e-01 |
| far9 | 308 | 392 | -0.35 | 0.22 / 0.12 / 0.00 / 0.00 ; 0.23 / 0.14 / 0.05 / 0.00 | 1.4e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 16 of 44 (sym7@16: 0.50 vs 0.48; sym7@128: 0.48 vs 0.43; sym7@512: 0.17 vs 0.15; ex3of8@16: 0.32 vs 0.24; ex3of8@32: 0.33 vs 0.28; ex3of8@64: 0.33 vs 0.29; ex3of8@128: 0.29 vs 0.27; ex3of8@512: 0.28 vs 0.24; band11@512: 0.51 vs 0.49; band11@1024: 0.49 vs 0.47; band11@2048: 0.43 vs 0.28; band11@4096: 0.34 vs 0.01; band11@8192: 0.35 vs 0.00; band11@16384: 0.27 vs 0.00; far9@16: 0.37 vs 0.26; far9@32: 0.26 vs 0.23). Of these, by more than 2 standard errors of the seed-to-seed spread: 10 (sym7@128, ex3of8@32, ex3of8@128, ex3of8@512, band11@512, band11@1024, band11@4096, band11@8192, band11@16384, far9@16).

Mean log2 ratio over targets where both learn: -0.11 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 1; clearly worse: 1; of 4. Largest compute used: 4.9e-01 of a GD run.

