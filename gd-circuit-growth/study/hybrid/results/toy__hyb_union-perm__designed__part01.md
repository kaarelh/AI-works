## hyb_union-perm on the designed suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| maj3 | 49 | 112 | -1.18 | 0.05 / 0.00 / 0.00 / 0.00 ; 0.18 / 0.04 / 0.00 / 0.00 | 2.1e-01 |
| maj9 | 86 | 263 | -1.61 | 0.16 / 0.00 / 0.00 / 0.00 ; 0.20 / 0.10 / 0.00 / 0.00 | 2.1e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 2 of 22 (maj3@16: 0.36 vs 0.33; maj9@16: 0.41 vs 0.35). Of these, by more than 2 standard errors of the seed-to-seed spread: 0.

Mean log2 ratio over targets where both learn: -1.40 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 2; clearly worse: 0; of 2. Largest compute used: 2.1e-01 of a GD run.

