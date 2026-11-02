## dfg13-perm on the dlsymdev suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| sym7 | 56 | 670 | -3.59 | 0.00 / 0.00 / 0.00 / 0.00 ; 0.48 / 0.32 / 0.02 / 0.00 | 1.5e-01 |
| ex3of8 | 123 | 1355 | -3.46 | 0.31 / 0.00 / 0.00 / 0.00 ; 0.29 / 0.27 / 0.17 / 0.00 | 1.6e-01 |
| band11 | 828 | 3253 | -1.97 | 0.50 / 0.33 / 0.00 / 0.00 ; 0.50 / 0.50 / 0.47 / 0.01 | 1.6e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 3 of 33 (ex3of8@16: 0.32 vs 0.24; ex3of8@32: 0.33 vs 0.28; ex3of8@64: 0.31 vs 0.29). Of these, by more than 2 standard errors of the seed-to-seed spread: 2 (ex3of8@16, ex3of8@32).

Mean log2 ratio over targets where both learn: -3.01 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 3; clearly worse: 0; of 3. Largest compute used: 1.6e-01 of a GD run.

