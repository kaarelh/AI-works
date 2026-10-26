## p9_sum-perm on the designed suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| dict | 16 | 47 | -1.55 | 0.00 / 0.00 / 0.00 / 0.00 ; 0.04 / 0.00 / 0.00 / 0.00 | 1.9e-01 |
| and3 | 25 | 94 | -1.94 | 0.03 / 0.00 / 0.00 / 0.00 ; 0.12 / 0.03 / 0.00 / 0.00 | 1.9e-01 |
| maj3 | 31 | 112 | -1.83 | 0.00 / 0.00 / 0.00 / 0.00 ; 0.18 / 0.04 / 0.00 / 0.00 | 1.9e-01 |
| maj9 | 80 | 263 | -1.72 | 0.15 / 0.00 / 0.00 / 0.00 ; 0.20 / 0.10 / 0.00 / 0.00 | 2.1e-01 |
| thr10 | 121 | 563 | -2.22 | 0.16 / 0.05 / 0.01 / 0.00 ; 0.22 / 0.12 / 0.06 / 0.02 | 5.5e-01 |
| par2 | 16 | 200 | -3.64 | 0.00 / 0.00 / 0.00 / 0.00 ; 0.45 / 0.00 / 0.00 / 0.00 | 1.9e-01 |
| par3 | 55 | 843 | -3.93 | 0.00 / 0.00 / 0.00 / 0.00 ; 0.50 / 0.48 / 0.00 / 0.00 | 1.9e-01 |
| par4 | 56 | 2728 | -5.61 | 0.00 / 0.00 / 0.00 / 0.00 ; 0.50 / 0.50 / 0.49 / 0.00 | 1.9e-01 |
| stair5 | 109 | 1514 | -3.79 | 0.39 / 0.00 / 0.00 / 0.00 ; 0.45 / 0.36 / 0.23 / 0.00 | 1.9e-01 |
| majpar | 60 | 1380 | -4.51 | 0.08 / 0.00 / 0.00 / 0.00 ; 0.47 / 0.33 / 0.12 / 0.00 | 1.9e-01 |
| parmaj | 142 | 743 | -2.39 | 0.47 / 0.00 / 0.00 / 0.00 ; 0.48 / 0.34 / 0.02 / 0.00 | 2.0e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 3 of 121 (maj3@16: 0.37 vs 0.33; maj9@16: 0.40 vs 0.35; thr10@16: 0.43 vs 0.39). Of these, by more than 2 standard errors of the seed-to-seed spread: 0.

Mean log2 ratio over targets where both learn: -3.01 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 11; clearly worse: 0; of 11. Largest compute used: 5.5e-01 of a GD run.

