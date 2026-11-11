## lowdeg-perm on the dlheld4 suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| sym11 | 7778 | 934 | +3.06 | 0.44 / 0.44 / 0.43 / 0.19 ; 0.48 / 0.36 / 0.08 / 0.00 | 9.2e-02 |
| ex4of9 | 6580 | 1073 | +2.62 | 0.24 / 0.24 / 0.24 / 0.25 ; 0.32 / 0.30 / 0.11 / 0.00 | 9.0e-02 |
| tail13 | 3992 | 612 | +2.71 | 0.25 / 0.25 / 0.25 / 0.10 ; 0.31 / 0.21 / 0.06 / 0.00 | 8.9e-02 |
| band10 | never | 5920 | +inf | 0.41 / 0.41 / 0.41 / 0.42 ; 0.45 / 0.44 / 0.43 / 0.21 | 8.9e-02 |
| ssym8 | 3873 | 1160 | +1.74 | 0.28 / 0.28 / 0.28 / 0.09 ; 0.36 / 0.33 / 0.12 / 0.00 | 8.9e-02 |
| symxor | 2569 | 1706 | +0.59 | 0.50 / 0.42 / 0.21 / 0.08 ; 0.50 / 0.49 / 0.38 / 0.00 | 8.9e-02 |
| symand | 761 | 498 | +0.61 | 0.33 / 0.17 / 0.07 / 0.02 ; 0.31 / 0.19 / 0.04 / 0.00 | 8.9e-02 |
| sumpar | 316 | 3487 | -3.47 | 0.39 / 0.13 / 0.01 / 0.00 ; 0.38 / 0.31 / 0.25 / 0.07 | 8.9e-02 |
| majsym | 978 | 1542 | -0.66 | 0.24 / 0.19 / 0.09 / 0.00 ; 0.38 / 0.25 / 0.14 / 0.00 | 8.9e-02 |
| dnf3x3 | 538 | 493 | +0.13 | 0.34 / 0.26 / 0.00 / 0.00 ; 0.28 / 0.18 / 0.01 / 0.00 | 8.9e-02 |
| h4rf0 | 98 | 349 | -1.82 | 0.24 / 0.01 / 0.01 / 0.01 ; 0.36 / 0.16 / 0.01 / 0.00 | 8.9e-02 |
| h4rf1 | 114 | 211 | -0.89 | 0.19 / 0.08 / 0.08 / 0.00 ; 0.20 / 0.09 / 0.03 / 0.00 | 8.9e-02 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 41 of 132 (sym11@256: 0.44 vs 0.36; sym11@512: 0.44 vs 0.25; sym11@1024: 0.43 vs 0.08; sym11@2048: 0.35 vs 0.00; sym11@4096: 0.19 vs 0.00; sym11@8192: 0.09 vs 0.00; sym11@16384: 0.11 vs 0.00; ex4of9@1024: 0.24 vs 0.11; ex4of9@2048: 0.24 vs 0.00; ex4of9@4096: 0.25 vs 0.00; ex4of9@8192: 0.03 vs 0.00; tail13@256: 0.25 vs 0.21; tail13@512: 0.25 vs 0.11; tail13@1024: 0.25 vs 0.06; tail13@2048: 0.22 vs 0.04; tail13@4096: 0.10 vs 0.00; tail13@8192: 0.06 vs 0.00; tail13@16384: 0.07 vs 0.00; band10@4096: 0.42 vs 0.21; band10@8192: 0.40 vs 0.00; band10@16384: 0.46 vs 0.00; ssym8@1024: 0.28 vs 0.12; ssym8@2048: 0.27 vs 0.00; ssym8@4096: 0.09 vs 0.00; symxor@2048: 0.11 vs 0.00; symxor@4096: 0.08 vs 0.00; symxor@8192: 0.06 vs 0.00; symand@16: 0.58 vs 0.42; symand@512: 0.13 vs 0.10; symand@1024: 0.07 vs 0.04; sumpar@16: 0.50 vs 0.43; sumpar@32: 0.46 vs 0.42; majsym@16: 0.48 vs 0.41; dnf3x3@32: 0.34 vs 0.30; dnf3x3@64: 0.34 vs 0.28; dnf3x3@128: 0.34 vs 0.22; dnf3x3@256: 0.26 vs 0.18; h4rf0@16: 0.48 vs 0.44; h4rf1@512: 0.08 vs 0.05; h4rf1@1024: 0.08 vs 0.03; h4rf1@2048: 0.04 vs 0.00). Of these, by more than 2 standard errors of the seed-to-seed spread: 33 (sym11@256, sym11@512, sym11@1024, sym11@2048, sym11@4096, sym11@8192, sym11@16384, ex4of9@1024, ex4of9@2048, ex4of9@4096, ex4of9@8192, tail13@512, tail13@1024, tail13@2048, tail13@4096, tail13@8192, tail13@16384, band10@8192, band10@16384, ssym8@1024, ssym8@2048, symxor@2048, symxor@4096, symxor@8192, symand@16, dnf3x3@32, dnf3x3@64, dnf3x3@128, dnf3x3@256, h4rf0@16, h4rf1@512, h4rf1@1024, h4rf1@2048).

Mean log2 ratio over targets where both learn: +0.42 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 4; clearly worse: 7; of 12. Largest compute used: 9.2e-02 of a GD run.

