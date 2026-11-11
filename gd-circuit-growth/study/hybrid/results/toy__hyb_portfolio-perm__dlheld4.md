## hyb_portfolio-perm on the dlheld4 suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| sym11 | 2386 | 934 | +1.35 | 0.46 / 0.39 / 0.15 / 0.00 ; 0.48 / 0.36 / 0.08 / 0.00 | 7.3e-01 |
| ex4of9 | 1658 | 1073 | +0.63 | 0.25 / 0.25 / 0.21 / 0.07 ; 0.32 / 0.30 / 0.11 / 0.00 | 5.3e-01 |
| tail13 | 436 | 612 | -0.49 | 0.26 / 0.15 / 0.04 / 0.00 ; 0.31 / 0.21 / 0.06 / 0.00 | 3.2e-01 |
| band10 | 3468 | 5920 | -0.77 | 0.41 / 0.41 / 0.41 / 0.00 ; 0.45 / 0.44 / 0.43 / 0.21 | 2.6e-01 |
| ssym8 | 1410 | 1160 | +0.28 | 0.34 / 0.28 / 0.19 / 0.00 ; 0.36 / 0.33 / 0.12 / 0.00 | 3.1e-01 |
| symxor | 766 | 1706 | -1.16 | 0.49 / 0.44 / 0.00 / 0.00 ; 0.50 / 0.49 / 0.38 / 0.00 | 2.3e-01 |
| symand | 289 | 498 | -0.78 | 0.28 / 0.11 / 0.01 / 0.00 ; 0.31 / 0.19 / 0.04 / 0.00 | 3.0e-01 |
| sumpar | 168 | 3487 | -4.37 | 0.29 / 0.04 / 0.00 / 0.00 ; 0.38 / 0.31 / 0.25 / 0.07 | 1.9e-01 |
| majsym | 352 | 1542 | -2.13 | 0.22 / 0.18 / 0.00 / 0.00 ; 0.38 / 0.25 / 0.14 / 0.00 | 1.9e-01 |
| dnf3x3 | 118 | 493 | -2.07 | 0.23 / 0.00 / 0.00 / 0.00 ; 0.28 / 0.18 / 0.01 / 0.00 | 2.0e-01 |
| h4rf0 | 48 | 349 | -2.86 | 0.03 / 0.01 / 0.00 / 0.00 ; 0.36 / 0.16 / 0.01 / 0.00 | 2.6e-01 |
| h4rf1 | 51 | 211 | -2.05 | 0.09 / 0.04 / 0.00 / 0.00 ; 0.20 / 0.09 / 0.03 / 0.00 | 2.0e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 8 of 132 (sym11@256: 0.39 vs 0.36; sym11@1024: 0.15 vs 0.08; sym11@2048: 0.13 vs 0.00; ex4of9@1024: 0.21 vs 0.11; ex4of9@2048: 0.05 vs 0.00; ex4of9@4096: 0.07 vs 0.00; ssym8@1024: 0.19 vs 0.12; symand@16: 0.48 vs 0.42). Of these, by more than 2 standard errors of the seed-to-seed spread: 5 (sym11@1024, sym11@2048, ex4of9@1024, ex4of9@2048, ex4of9@4096).

Mean log2 ratio over targets where both learn: -1.20 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 9; clearly worse: 3; of 12. Largest compute used: 7.3e-01 of a GD run.

