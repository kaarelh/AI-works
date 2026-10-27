## p10_sum-perm on the dlsymdev suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| sym7 | 55 | 670 | -3.61 | 0.00 / 0.00 / 0.00 / 0.00 ; 0.48 / 0.32 / 0.02 / 0.00 | 2.2e-01 |
| ex3of8 | 118 | 1355 | -3.52 | 0.28 / 0.00 / 0.00 / 0.00 ; 0.29 / 0.27 / 0.17 / 0.00 | 2.3e-01 |
| band11 | 829 | 3253 | -1.97 | 0.50 / 0.33 / 0.00 / 0.00 ; 0.50 / 0.50 / 0.47 / 0.01 | 2.1e-01 |
| far9 | 71 | 392 | -2.47 | 0.12 / 0.00 / 0.00 / 0.00 ; 0.23 / 0.14 / 0.05 / 0.00 | 2.1e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 1 of 44 (ex3of8@16: 0.30 vs 0.24). Of these, by more than 2 standard errors of the seed-to-seed spread: 0.

Mean log2 ratio over targets where both learn: -2.89 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 4; clearly worse: 0; of 4. Largest compute used: 2.3e-01 of a GD run.

