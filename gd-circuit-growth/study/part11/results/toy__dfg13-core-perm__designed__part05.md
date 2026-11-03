## dfg13-core-perm on the designed suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| sparsepoly | 82 | 2205 | -4.76 | 0.12 / 0.00 / 0.00 / 0.00 ; 0.24 / 0.15 / 0.13 / 0.00 | 9.1e-03 |
| rand0 | 16 | 222 | -3.80 | 0.03 / 0.00 / 0.00 / 0.00 ; 0.43 / 0.05 / 0.00 / 0.00 | 8.3e-03 |
| rand1 | 63 | 463 | -2.87 | 0.10 / 0.00 / 0.00 / 0.00 ; 0.31 / 0.18 / 0.00 / 0.00 | 9.0e-03 |
| rand2 | 28 | 91 | -1.69 | 0.06 / 0.00 / 0.00 / 0.00 ; 0.13 / 0.06 / 0.03 / 0.00 | 9.4e-03 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 3 of 44 (sparsepoly@16: 0.39 vs 0.35; rand1@16: 0.43 vs 0.39; rand1@32: 0.43 vs 0.34). Of these, by more than 2 standard errors of the seed-to-seed spread: 3 (sparsepoly@16, rand1@16, rand1@32).

Mean log2 ratio over targets where both learn: -3.28 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 4; clearly worse: 0; of 4. Largest compute used: 9.4e-03 of a GD run.

