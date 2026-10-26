## hgb on the dlheld4 suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| sym11 | never | 934 | +inf | 0.48 / 0.44 / 0.34 / 0.21 ; 0.48 / 0.36 / 0.08 / 0.00 | 3.0e-03 |
| ex4of9 | never | 1073 | +inf | 0.29 / 0.28 / 0.25 / 0.19 ; 0.32 / 0.30 / 0.11 / 0.00 | 3.0e-03 |
| tail13 | never | 612 | +inf | 0.30 / 0.29 / 0.21 / 0.14 ; 0.31 / 0.21 / 0.06 / 0.00 | 3.0e-03 |
| band10 | never | 5920 | +inf | 0.44 / 0.44 / 0.43 / 0.41 ; 0.45 / 0.44 / 0.43 / 0.21 | 3.0e-03 |
| ssym8 | 8072 | 1160 | +2.80 | 0.34 / 0.33 / 0.29 / 0.24 ; 0.36 / 0.33 / 0.12 / 0.00 | 3.0e-03 |
| symxor | 6909 | 1706 | +2.02 | 0.50 / 0.49 / 0.42 / 0.17 ; 0.50 / 0.49 / 0.38 / 0.00 | 3.0e-03 |
| symand | 1307 | 498 | +1.39 | 0.30 / 0.16 / 0.12 / 0.03 ; 0.31 / 0.19 / 0.04 / 0.00 | 3.0e-03 |
| sumpar | never | 3487 | +inf | 0.35 / 0.31 / 0.24 / 0.20 ; 0.38 / 0.31 / 0.25 / 0.07 | 3.0e-03 |
| majsym | 2840 | 1542 | +0.88 | 0.32 / 0.26 / 0.16 / 0.05 ; 0.38 / 0.25 / 0.14 / 0.00 | 3.0e-03 |
| dnf3x3 | 148 | 493 | -1.73 | 0.27 / 0.00 / 0.00 / 0.00 ; 0.28 / 0.18 / 0.01 / 0.00 | 3.0e-03 |
| h4rf0 | 160 | 349 | -1.13 | 0.32 / 0.01 / 0.00 / 0.00 ; 0.36 / 0.16 / 0.01 / 0.00 | 3.0e-03 |
| h4rf1 | 61 | 211 | -1.79 | 0.08 / 0.06 / 0.00 / 0.00 ; 0.20 / 0.09 / 0.03 / 0.00 | 3.0e-03 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 56 of 132 (sym11@128: 0.47 vs 0.44; sym11@256: 0.44 vs 0.36; sym11@512: 0.42 vs 0.25; sym11@1024: 0.34 vs 0.08; sym11@2048: 0.29 vs 0.00; sym11@4096: 0.21 vs 0.00; sym11@8192: 0.16 vs 0.00; sym11@16384: 0.14 vs 0.00; ex4of9@1024: 0.25 vs 0.11; ex4of9@2048: 0.24 vs 0.00; ex4of9@4096: 0.19 vs 0.00; ex4of9@8192: 0.16 vs 0.00; ex4of9@16384: 0.11 vs 0.00; tail13@256: 0.29 vs 0.21; tail13@512: 0.25 vs 0.11; tail13@1024: 0.21 vs 0.06; tail13@2048: 0.17 vs 0.04; tail13@4096: 0.14 vs 0.00; tail13@8192: 0.13 vs 0.00; tail13@16384: 0.12 vs 0.00; band10@4096: 0.41 vs 0.21; band10@8192: 0.40 vs 0.00; band10@16384: 0.41 vs 0.00; ssym8@1024: 0.29 vs 0.12; ssym8@2048: 0.25 vs 0.00; ssym8@4096: 0.24 vs 0.00; ssym8@8192: 0.10 vs 0.00; ssym8@16384: 0.05 vs 0.00; symxor@1024: 0.42 vs 0.38; symxor@2048: 0.33 vs 0.00; symxor@4096: 0.17 vs 0.00; symxor@8192: 0.08 vs 0.00; symxor@16384: 0.04 vs 0.00; symand@16: 0.58 vs 0.42; symand@32: 0.47 vs 0.38; symand@512: 0.14 vs 0.10; symand@1024: 0.12 vs 0.04; symand@2048: 0.06 vs 0.02; symand@4096: 0.03 vs 0.00; sumpar@16: 0.50 vs 0.43; sumpar@32: 0.50 vs 0.42; sumpar@2048: 0.22 vs 0.19; sumpar@4096: 0.20 vs 0.07; sumpar@8192: 0.20 vs 0.00; sumpar@16384: 0.21 vs 0.00; majsym@16: 0.48 vs 0.41; majsym@32: 0.48 vs 0.41; majsym@512: 0.20 vs 0.18; majsym@2048: 0.15 vs 0.07; majsym@4096: 0.05 vs 0.00; majsym@8192: 0.07 vs 0.00; majsym@16384: 0.06 vs 0.00; dnf3x3@32: 0.34 vs 0.30; h4rf0@16: 0.48 vs 0.44; h4rf0@32: 0.48 vs 0.41; h4rf1@32: 0.33 vs 0.27). Of these, by more than 2 standard errors of the seed-to-seed spread: 46 (sym11@256, sym11@512, sym11@1024, sym11@2048, sym11@4096, sym11@8192, sym11@16384, ex4of9@1024, ex4of9@2048, ex4of9@4096, ex4of9@8192, ex4of9@16384, tail13@256, tail13@512, tail13@1024, tail13@2048, tail13@4096, tail13@8192, tail13@16384, band10@8192, band10@16384, ssym8@1024, ssym8@2048, ssym8@4096, ssym8@8192, ssym8@16384, symxor@2048, symxor@4096, symxor@8192, symxor@16384, symand@16, symand@512, symand@1024, symand@2048, symand@4096, sumpar@2048, sumpar@4096, sumpar@8192, sumpar@16384, majsym@2048, majsym@4096, majsym@8192, dnf3x3@32, h4rf0@16, h4rf0@32, h4rf1@32).

Mean log2 ratio over targets where both learn: +0.35 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 3; clearly worse: 9; of 12. Largest compute used: 3.0e-03 of a GD run.

