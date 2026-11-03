## dfg13-core-perm on the dlsymdev suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| sym7 | 55 | 670 | -3.61 | 0.00 / 0.00 / 0.00 / 0.00 ; 0.48 / 0.32 / 0.02 / 0.00 | 7.0e-03 |
| ex3of8 | 94 | 1355 | -3.85 | 0.22 / 0.00 / 0.00 / 0.00 ; 0.29 / 0.27 / 0.17 / 0.00 | 8.5e-03 |
| band11 | 889 | 3253 | -1.87 | 0.50 / 0.49 / 0.00 / 0.00 ; 0.50 / 0.50 / 0.47 / 0.01 | 6.9e-03 |
| far9 | 86 | 392 | -2.18 | 0.18 / 0.00 / 0.00 / 0.00 ; 0.23 / 0.14 / 0.05 / 0.00 | 7.2e-03 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 0 of 44. Of these, by more than 2 standard errors of the seed-to-seed spread: 0.

Mean log2 ratio over targets where both learn: -2.88 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 4; clearly worse: 0; of 4. Largest compute used: 8.5e-03 of a GD run.

