## hyb_portfolio2-perm on the dlheld4 suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| sym11 | 203 | 934 | -2.20 | 0.46 / 0.00 / 0.00 / 0.00 ; 0.48 / 0.36 / 0.08 / 0.00 | 2.2e-01 |
| ex4of9 | 194 | 1073 | -2.47 | 0.25 / 0.00 / 0.00 / 0.00 ; 0.32 / 0.30 / 0.11 / 0.00 | 2.1e-01 |
| tail13 | 176 | 612 | -1.80 | 0.26 / 0.00 / 0.00 / 0.00 ; 0.31 / 0.21 / 0.06 / 0.00 | 2.2e-01 |
| band10 | 432 | 5920 | -3.78 | 0.41 / 0.41 / 0.00 / 0.00 ; 0.45 / 0.44 / 0.43 / 0.21 | 2.1e-01 |
| ssym8 | 157 | 1160 | -2.89 | 0.34 / 0.00 / 0.00 / 0.00 ; 0.36 / 0.33 / 0.12 / 0.00 | 2.2e-01 |
| symxor | 403 | 1706 | -2.08 | 0.49 / 0.29 / 0.00 / 0.00 ; 0.50 / 0.49 / 0.38 / 0.00 | 2.0e-01 |
| symand | 170 | 498 | -1.55 | 0.28 / 0.00 / 0.00 / 0.00 ; 0.31 / 0.19 / 0.04 / 0.00 | 2.3e-01 |
| sumpar | 164 | 3487 | -4.41 | 0.29 / 0.03 / 0.00 / 0.00 ; 0.38 / 0.31 / 0.25 / 0.07 | 2.0e-01 |
| majsym | 189 | 1542 | -3.03 | 0.22 / 0.01 / 0.00 / 0.00 ; 0.38 / 0.25 / 0.14 / 0.00 | 2.8e-01 |
| dnf3x3 | 118 | 493 | -2.07 | 0.23 / 0.00 / 0.00 / 0.00 ; 0.28 / 0.18 / 0.01 / 0.00 | 2.2e-01 |
| h4rf0 | 48 | 349 | -2.86 | 0.03 / 0.01 / 0.00 / 0.00 ; 0.36 / 0.16 / 0.01 / 0.00 | 3.3e-01 |
| h4rf1 | 56 | 211 | -1.91 | 0.10 / 0.04 / 0.00 / 0.00 ; 0.20 / 0.09 / 0.03 / 0.00 | 2.1e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 1 of 132 (symand@16: 0.48 vs 0.42). Of these, by more than 2 standard errors of the seed-to-seed spread: 0.

Mean log2 ratio over targets where both learn: -2.59 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 12; clearly worse: 0; of 12. Largest compute used: 3.3e-01 of a GD run.

