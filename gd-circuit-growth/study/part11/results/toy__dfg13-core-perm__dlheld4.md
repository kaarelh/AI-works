## dfg13-core-perm on the dlheld4 suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| sym11 | 187 | 934 | -2.32 | 0.44 / 0.00 / 0.00 / 0.00 ; 0.48 / 0.36 / 0.08 / 0.00 | 8.0e-03 |
| ex4of9 | 193 | 1073 | -2.48 | 0.24 / 0.00 / 0.00 / 0.00 ; 0.32 / 0.30 / 0.11 / 0.00 | 7.8e-03 |
| tail13 | 148 | 612 | -2.05 | 0.25 / 0.00 / 0.00 / 0.00 ; 0.31 / 0.21 / 0.06 / 0.00 | 8.8e-03 |
| band10 | 432 | 5920 | -3.78 | 0.41 / 0.41 / 0.00 / 0.00 ; 0.45 / 0.44 / 0.43 / 0.21 | 7.7e-03 |
| ssym8 | 100 | 1160 | -3.53 | 0.28 / 0.00 / 0.00 / 0.00 ; 0.36 / 0.33 / 0.12 / 0.00 | 7.4e-03 |
| symxor | 461 | 1706 | -1.89 | 0.50 / 0.42 / 0.00 / 0.00 ; 0.50 / 0.49 / 0.38 / 0.00 | 1.8e-02 |
| symand | 100 | 498 | -2.31 | 0.28 / 0.00 / 0.00 / 0.00 ; 0.31 / 0.19 / 0.04 / 0.00 | 7.9e-03 |
| sumpar | 146 | 3487 | -4.58 | 0.50 / 0.06 / 0.00 / 0.00 ; 0.38 / 0.31 / 0.25 / 0.07 | 1.9e-02 |
| majsym | 96 | 1542 | -4.00 | 0.24 / 0.00 / 0.00 / 0.00 ; 0.38 / 0.25 / 0.14 / 0.00 | 1.9e-02 |
| dnf3x3 | 212 | 493 | -1.21 | 0.34 / 0.01 / 0.00 / 0.00 ; 0.28 / 0.18 / 0.01 / 0.00 | 1.4e-02 |
| h4rf0 | 55 | 349 | -2.66 | 0.03 / 0.01 / 0.00 / 0.00 ; 0.36 / 0.16 / 0.01 / 0.00 | 1.8e-02 |
| h4rf1 | 29 | 211 | -2.88 | 0.08 / 0.03 / 0.00 / 0.00 ; 0.20 / 0.09 / 0.03 / 0.00 | 1.8e-02 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 9 of 132 (symand@16: 0.58 vs 0.42; sumpar@16: 0.50 vs 0.43; sumpar@32: 0.50 vs 0.42; sumpar@64: 0.50 vs 0.38; majsym@16: 0.50 vs 0.41; dnf3x3@32: 0.34 vs 0.30; dnf3x3@64: 0.34 vs 0.28; dnf3x3@128: 0.34 vs 0.22; h4rf0@16: 0.49 vs 0.44). Of these, by more than 2 standard errors of the seed-to-seed spread: 6 (symand@16, sumpar@64, dnf3x3@32, dnf3x3@64, dnf3x3@128, h4rf0@16).

Mean log2 ratio over targets where both learn: -2.81 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 12; clearly worse: 0; of 12. Largest compute used: 1.9e-02 of a GD run.

