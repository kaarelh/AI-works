## hyb_portfolio-perm on the dlheld3 suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| cnf3 | 146 | 489 | -1.75 | 0.22 / 0.01 / 0.00 / 0.00 ; 0.28 / 0.17 / 0.02 / 0.00 | 2.0e-01 |
| sym9 | 1229 | 787 | +0.64 | 0.49 / 0.39 / 0.13 / 0.00 ; 0.47 / 0.33 / 0.04 / 0.00 | 6.6e-01 |
| dlist8 | 24 | 104 | -2.12 | 0.10 / 0.01 / 0.00 / 0.00 ; 0.16 / 0.05 / 0.01 / 0.00 | 2.9e-01 |
| thrint | 149 | 546 | -1.88 | 0.16 / 0.04 / 0.00 / 0.00 ; 0.21 / 0.13 / 0.05 / 0.00 | 2.6e-01 |
| par3or | 62 | 1050 | -4.07 | 0.09 / 0.00 / 0.00 / 0.00 ; 0.39 / 0.37 / 0.10 / 0.00 | 1.9e-01 |
| poly4 | 177 | 10199 | -5.85 | 0.36 / 0.00 / 0.00 / 0.00 ; 0.49 / 0.43 / 0.36 / 0.25 | 1.9e-01 |
| mixmaj | 96 | 507 | -2.40 | 0.16 / 0.00 / 0.00 / 0.00 ; 0.36 / 0.22 / 0.02 / 0.00 | 1.9e-01 |
| mux11 | 523 | 1527 | -1.55 | 0.44 / 0.27 / 0.00 / 0.00 ; 0.43 / 0.34 / 0.19 / 0.00 | 2.2e-01 |
| h3rf0 | 46 | 109 | -1.23 | 0.08 / 0.02 / 0.00 / 0.00 ; 0.16 / 0.07 / 0.06 / 0.02 | 1.9e-01 |
| h3rf1 | 60 | 123 | -1.03 | 0.10 / 0.02 / 0.00 / 0.00 ; 0.16 / 0.09 / 0.05 / 0.00 | 2.0e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 4 of 110 (sym9@128: 0.46 vs 0.43; sym9@256: 0.39 vs 0.33; sym9@1024: 0.13 vs 0.04; thrint@16: 0.42 vs 0.39). Of these, by more than 2 standard errors of the seed-to-seed spread: 1 (sym9@1024).

Mean log2 ratio over targets where both learn: -2.12 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 9; clearly worse: 1; of 10. Largest compute used: 6.6e-01 of a GD run.

