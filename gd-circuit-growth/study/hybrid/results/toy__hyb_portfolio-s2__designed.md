## hyb_portfolio-s2 on the designed suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| par4 | 55 | 2728 | -5.63 | 0.00 / 0.00 / 0.00 / 0.00 ; 0.50 / 0.50 / 0.49 / 0.00 | 1.9e-01 |
| stair5 | 106 | 1514 | -3.83 | 0.34 / 0.00 / 0.00 / 0.00 ; 0.45 / 0.36 / 0.23 / 0.00 | 1.9e-01 |
| majpar | 60 | 1380 | -4.53 | 0.07 / 0.00 / 0.00 / 0.00 ; 0.47 / 0.33 / 0.12 / 0.00 | 1.9e-01 |
| parmaj | 213 | 743 | -1.80 | 0.46 / 0.00 / 0.00 / 0.00 ; 0.48 / 0.34 / 0.02 / 0.00 | 1.9e-01 |
| mux | 70 | 1156 | -4.04 | 0.11 / 0.01 / 0.00 / 0.00 ; 0.43 / 0.35 / 0.12 / 0.00 | 1.9e-01 |
| dnf3 | 150 | 505 | -1.75 | 0.26 / 0.01 / 0.00 / 0.00 ; 0.30 / 0.17 / 0.02 / 0.00 | 2.0e-01 |
| dlist5 | 23 | 110 | -2.26 | 0.04 / 0.00 / 0.00 / 0.00 ; 0.16 / 0.05 / 0.01 / 0.00 | 2.0e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 1 of 77 (mux@16: 0.49 vs 0.46). Of these, by more than 2 standard errors of the seed-to-seed spread: 0.

Mean log2 ratio over targets where both learn: -3.41 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 7; clearly worse: 0; of 7. Largest compute used: 2.0e-01 of a GD run.

