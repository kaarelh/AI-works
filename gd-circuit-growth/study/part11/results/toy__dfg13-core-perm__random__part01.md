## dfg13-core-perm on the random suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| rf00 | 30 | 98 | -1.72 | 0.06 / 0.00 / 0.00 / 0.00 ; 0.16 / 0.04 / 0.00 / 0.00 | 6.9e-03 |
| rf01 | 74 | 467 | -2.67 | 0.13 / 0.00 / 0.00 / 0.00 ; 0.37 / 0.19 / 0.00 / 0.00 | 6.8e-03 |
| rf02 | 49 | 266 | -2.44 | 0.00 / 0.00 / 0.00 / 0.00 ; 0.29 / 0.11 / 0.00 / 0.00 | 5.5e-03 |
| rf03 | 108 | 425 | -1.98 | 0.19 / 0.00 / 0.00 / 0.00 ; 0.34 / 0.17 / 0.00 / 0.00 | 9.2e-03 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 2 of 44 (rf00@16: 0.46 vs 0.36; rf03@16: 0.49 vs 0.43). Of these, by more than 2 standard errors of the seed-to-seed spread: 2 (rf00@16, rf03@16).

Mean log2 ratio over targets where both learn: -2.20 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 4; clearly worse: 0; of 4. Largest compute used: 9.2e-03 of a GD run.

