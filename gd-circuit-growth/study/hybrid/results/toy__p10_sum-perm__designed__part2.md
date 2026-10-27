## p10_sum-perm on the designed suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| par3 | 55 | 843 | -3.93 | 0.00 / 0.00 / 0.00 / 0.00 ; 0.50 / 0.48 / 0.00 / 0.00 | 1.9e-01 |
| par4 | 56 | 2728 | -5.61 | 0.00 / 0.00 / 0.00 / 0.00 ; 0.50 / 0.50 / 0.49 / 0.00 | 1.9e-01 |
| stair5 | 109 | 1514 | -3.79 | 0.39 / 0.00 / 0.00 / 0.00 ; 0.45 / 0.36 / 0.23 / 0.00 | 1.9e-01 |
| majpar | 60 | 1380 | -4.51 | 0.08 / 0.00 / 0.00 / 0.00 ; 0.47 / 0.33 / 0.12 / 0.00 | 2.0e-01 |
| parmaj | 110 | 743 | -2.75 | 0.47 / 0.00 / 0.00 / 0.00 ; 0.48 / 0.34 / 0.02 / 0.00 | 2.0e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 0 of 55. Of these, by more than 2 standard errors of the seed-to-seed spread: 0.

Mean log2 ratio over targets where both learn: -4.12 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 5; clearly worse: 0; of 5. Largest compute used: 2.0e-01 of a GD run.

