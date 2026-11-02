## dfg13-perm on the random suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| rf00 | 32 | 98 | -1.62 | 0.08 / 0.00 / 0.00 / 0.00 ; 0.16 / 0.04 / 0.00 / 0.00 | 1.4e-01 |
| rf01 | 52 | 467 | -3.18 | 0.07 / 0.00 / 0.00 / 0.00 ; 0.37 / 0.19 / 0.00 / 0.00 | 1.4e-01 |
| rf02 | 51 | 266 | -2.37 | 0.00 / 0.00 / 0.00 / 0.00 ; 0.29 / 0.11 / 0.00 / 0.00 | 1.4e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 2 of 33 (rf02@16: 0.34 vs 0.28; rf02@32: 0.31 vs 0.28). Of these, by more than 2 standard errors of the seed-to-seed spread: 0.

Mean log2 ratio over targets where both learn: -2.39 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 3; clearly worse: 0; of 3. Largest compute used: 1.4e-01 of a GD run.

