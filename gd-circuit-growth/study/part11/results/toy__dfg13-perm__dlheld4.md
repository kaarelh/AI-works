## dfg13-perm on the dlheld4 suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| sym11 | 167 | 934 | -2.48 | 0.49 / 0.00 / 0.00 / 0.00 ; 0.48 / 0.36 / 0.08 / 0.00 | 1.6e-01 |
| ex4of9 | 205 | 1073 | -2.39 | 0.33 / 0.00 / 0.00 / 0.00 ; 0.32 / 0.30 / 0.11 / 0.00 | 1.5e-01 |
| tail13 | 134 | 612 | -2.19 | 0.33 / 0.00 / 0.00 / 0.00 ; 0.31 / 0.21 / 0.06 / 0.00 | 1.6e-01 |
| band10 | 440 | 5920 | -3.75 | 0.46 / 0.45 / 0.00 / 0.00 ; 0.45 / 0.44 / 0.43 / 0.21 | 1.5e-01 |
| ssym8 | 148 | 1160 | -2.97 | 0.38 / 0.00 / 0.00 / 0.00 ; 0.36 / 0.33 / 0.12 / 0.00 | 1.6e-01 |
| symxor | 406 | 1706 | -2.07 | 0.50 / 0.29 / 0.00 / 0.00 ; 0.50 / 0.49 / 0.38 / 0.00 | 1.4e-01 |
| symand | 149 | 498 | -1.74 | 0.33 / 0.01 / 0.00 / 0.00 ; 0.31 / 0.19 / 0.04 / 0.00 | 1.6e-01 |
| sumpar | 181 | 3487 | -4.27 | 0.37 / 0.03 / 0.00 / 0.00 ; 0.38 / 0.31 / 0.25 / 0.07 | 1.5e-01 |
| majsym | 102 | 1542 | -3.92 | 0.27 / 0.00 / 0.00 / 0.00 ; 0.38 / 0.25 / 0.14 / 0.00 | 1.5e-01 |
| dnf3x3 | 193 | 493 | -1.35 | 0.30 / 0.01 / 0.00 / 0.00 ; 0.28 / 0.18 / 0.01 / 0.00 | 1.6e-01 |
| h4rf0 | 55 | 349 | -2.66 | 0.03 / 0.01 / 0.00 / 0.00 ; 0.36 / 0.16 / 0.01 / 0.00 | 1.6e-01 |
| h4rf1 | 96 | 211 | -1.14 | 0.13 / 0.03 / 0.00 / 0.00 ; 0.20 / 0.09 / 0.03 / 0.00 | 1.5e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 8 of 132 (ex4of9@16: 0.41 vs 0.31; ex4of9@32: 0.36 vs 0.30; tail13@16: 0.44 vs 0.36; tail13@32: 0.41 vs 0.36; band10@16: 0.48 vs 0.45; ssym8@16: 0.42 vs 0.36; ssym8@32: 0.41 vs 0.36; dnf3x3@64: 0.30 vs 0.28). Of these, by more than 2 standard errors of the seed-to-seed spread: 4 (ex4of9@16, ex4of9@32, tail13@16, band10@16).

Mean log2 ratio over targets where both learn: -2.58 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 12; clearly worse: 0; of 12. Largest compute used: 1.6e-01 of a GD run.

