## dfg13-lenient-perm on the designed suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| dict | 16 | 47 | -1.55 | 0.00 / 0.00 / 0.00 / 0.00 ; 0.04 / 0.00 / 0.00 / 0.00 | 1.4e-01 |
| and3 | 78 | 94 | -0.27 | 0.14 / 0.00 / 0.00 / 0.00 ; 0.12 / 0.03 / 0.00 / 0.00 | 1.4e-01 |
| maj3 | 56 | 112 | -1.01 | 0.08 / 0.00 / 0.00 / 0.00 ; 0.18 / 0.04 / 0.00 / 0.00 | 1.4e-01 |
| maj9 | 96 | 263 | -1.46 | 0.17 / 0.00 / 0.00 / 0.00 ; 0.20 / 0.10 / 0.00 / 0.00 | 1.7e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 3 of 44 (and3@16: 0.24 vs 0.13; and3@32: 0.18 vs 0.12; and3@64: 0.14 vs 0.12). Of these, by more than 2 standard errors of the seed-to-seed spread: 2 (and3@16, and3@32).

Mean log2 ratio over targets where both learn: -1.07 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 4; clearly worse: 0; of 4. Largest compute used: 1.7e-01 of a GD run.

