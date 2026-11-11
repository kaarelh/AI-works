## dfg-v1.1 on the designed_d60 suite (d = 60)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| maj9 | 227 | 625 | -1.46 | 0.26 / 0.09 / 0.01 / 0.00 ; 0.26 / 0.14 / 0.08 / 0.00 | 4.6e-01 |
| majpar | 63 | 3466 | -5.78 | 0.09 / 0.02 / 0.00 / 0.00 ; 0.49 / 0.43 / 0.23 / 0.09 | 1.7e-01 |
| mux | 137 | 2848 | -4.38 | 0.29 / 0.00 / 0.00 / 0.00 ; 0.42 / 0.38 / 0.31 / 0.00 | 1.7e-01 |
| par2 | 16 | 427 | -4.74 | 0.00 / 0.00 / 0.00 / 0.00 ; 0.50 / 0.37 / 0.00 / 0.00 | 1.7e-01 |
| par3 | 28 | 3410 | -6.94 | 0.00 / 0.00 / 0.00 / 0.00 ; 0.50 / 0.49 / 0.49 / 0.00 | 1.7e-01 |
| par4 | 56 | 14255 | -8.00 | 0.00 / 0.00 / 0.00 / 0.00 ; 0.51 / 0.51 / 0.49 / 0.50 | 1.7e-01 |
| stair5 | 110 | 3487 | -4.99 | 0.45 / 0.00 / 0.00 / 0.00 ; 0.46 / 0.41 / 0.35 / 0.04 | 1.7e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 0 of 77. Of these, by more than 2 standard errors of the seed-to-seed spread: 0.

Mean log2 ratio over targets where both learn: -5.18 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 7; clearly worse: 0; of 7. Largest compute used: 4.6e-01 of a GD run.

