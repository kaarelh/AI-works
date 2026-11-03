## dfg13-nobg-perm on the designed suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| dict | 16 | 47 | -1.55 | 0.00 / 0.00 / 0.00 / 0.00 ; 0.04 / 0.00 / 0.00 / 0.00 | 1.4e-01 |
| and3 | 83 | 94 | -0.18 | 0.16 / 0.00 / 0.00 / 0.00 ; 0.12 / 0.03 / 0.00 / 0.00 | 1.4e-01 |
| maj3 | 81 | 112 | -0.47 | 0.15 / 0.00 / 0.00 / 0.00 ; 0.18 / 0.04 / 0.00 / 0.00 | 1.4e-01 |
| maj9 | 85 | 263 | -1.62 | 0.17 / 0.00 / 0.00 / 0.00 ; 0.20 / 0.10 / 0.00 / 0.00 | 1.5e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 5 of 44 (and3@64: 0.16 vs 0.12; maj3@16: 0.50 vs 0.33; maj3@32: 0.50 vs 0.24; maj9@16: 0.49 vs 0.35; maj9@32: 0.49 vs 0.27). Of these, by more than 2 standard errors of the seed-to-seed spread: 0.

Mean log2 ratio over targets where both learn: -0.96 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 3; clearly worse: 0; of 4. Largest compute used: 1.5e-01 of a GD run.

