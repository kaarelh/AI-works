## dfg13-noeig-perm on the dlsymdev suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| sym7 | 56 | 670 | -3.59 | 0.00 / 0.00 / 0.00 / 0.00 ; 0.48 / 0.32 / 0.02 / 0.00 | 1.6e-01 |
| ex3of8 | 103 | 1355 | -3.71 | 0.33 / 0.00 / 0.00 / 0.00 ; 0.29 / 0.27 / 0.17 / 0.00 | 1.6e-01 |
| band11 | 893 | 3253 | -1.87 | 0.50 / 0.50 / 0.00 / 0.00 ; 0.50 / 0.50 / 0.47 / 0.01 | 1.6e-01 |
| far9 | 95 | 392 | -2.05 | 0.22 / 0.00 / 0.00 / 0.00 ; 0.23 / 0.14 / 0.05 / 0.00 | 1.4e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 7 of 44 (sym7@16: 0.50 vs 0.48; ex3of8@16: 0.32 vs 0.24; ex3of8@32: 0.33 vs 0.28; ex3of8@64: 0.33 vs 0.29; band11@512: 0.51 vs 0.49; far9@16: 0.37 vs 0.26; far9@32: 0.26 vs 0.23). Of these, by more than 2 standard errors of the seed-to-seed spread: 3 (ex3of8@32, band11@512, far9@16).

Mean log2 ratio over targets where both learn: -2.80 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 4; clearly worse: 0; of 4. Largest compute used: 1.6e-01 of a GD run.

