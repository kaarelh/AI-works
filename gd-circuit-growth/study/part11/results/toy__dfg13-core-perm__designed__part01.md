## dfg13-core-perm on the designed suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| dict | 16 | 47 | -1.55 | 0.00 / 0.00 / 0.00 / 0.00 ; 0.04 / 0.00 / 0.00 / 0.00 | 5.5e-03 |
| and3 | 37 | 94 | -1.36 | 0.00 / 0.00 / 0.00 / 0.00 ; 0.12 / 0.03 / 0.00 / 0.00 | 5.5e-03 |
| maj3 | 49 | 112 | -1.20 | 0.00 / 0.00 / 0.00 / 0.00 ; 0.18 / 0.04 / 0.00 / 0.00 | 5.8e-03 |
| maj9 | 110 | 263 | -1.25 | 0.46 / 0.00 / 0.00 / 0.00 ; 0.20 / 0.10 / 0.00 / 0.00 | 7.9e-03 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 4 of 44 (maj3@16: 0.37 vs 0.33; maj9@16: 0.43 vs 0.35; maj9@32: 0.49 vs 0.27; maj9@64: 0.46 vs 0.20). Of these, by more than 2 standard errors of the seed-to-seed spread: 2 (maj9@32, maj9@64).

Mean log2 ratio over targets where both learn: -1.34 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 4; clearly worse: 0; of 4. Largest compute used: 7.9e-03 of a GD run.

