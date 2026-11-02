## dfg13-strict-perm on the designed suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| dict | 31 | 47 | -0.61 | 0.00 / 0.00 / 0.00 / 0.00 ; 0.04 / 0.00 / 0.00 / 0.00 | 1.4e-01 |
| and3 | 51 | 94 | -0.88 | 0.06 / 0.00 / 0.00 / 0.00 ; 0.12 / 0.03 / 0.00 / 0.00 | 1.4e-01 |
| maj3 | 50 | 112 | -1.17 | 0.03 / 0.00 / 0.00 / 0.00 ; 0.18 / 0.04 / 0.00 / 0.00 | 1.4e-01 |
| maj9 | 94 | 263 | -1.49 | 0.22 / 0.00 / 0.00 / 0.00 ; 0.20 / 0.10 / 0.00 / 0.00 | 1.4e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 3 of 44 (and3@16: 0.24 vs 0.13; and3@32: 0.18 vs 0.12; maj9@64: 0.22 vs 0.20). Of these, by more than 2 standard errors of the seed-to-seed spread: 2 (and3@16, and3@32).

Mean log2 ratio over targets where both learn: -1.04 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 4; clearly worse: 0; of 4. Largest compute used: 1.4e-01 of a GD run.

