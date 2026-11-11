## hyb_portfolio on the dlheld2 suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| thr20 | 116 | 593 | -2.35 | 0.17 / 0.06 / 0.02 / 0.01 ; 0.19 / 0.12 / 0.06 / 0.02 | 3.8e-01 |
| maj21 | 123 | 413 | -1.75 | 0.18 / 0.04 / 0.00 / 0.00 ; 0.20 / 0.12 / 0.02 / 0.00 | 1.9e-01 |
| xmaj | 62 | 1552 | -4.66 | 0.08 / 0.00 / 0.00 / 0.00 ; 0.50 / 0.49 / 0.25 / 0.00 | 1.9e-01 |
| dnf4x2 | 112 | 440 | -1.97 | 0.20 / 0.00 / 0.00 / 0.00 ; 0.26 / 0.16 / 0.01 / 0.00 | 3.1e-01 |
| sym8 | 396 | 504 | -0.35 | 0.29 / 0.14 / 0.01 / 0.00 ; 0.36 / 0.23 / 0.05 / 0.00 | 3.0e-01 |
| h2rf0 | 101 | 527 | -2.38 | 0.15 / 0.05 / 0.00 / 0.00 ; 0.38 / 0.24 / 0.02 / 0.00 | 2.1e-01 |
| h2rf1 | 32 | 127 | -2.01 | 0.06 / 0.03 / 0.00 / 0.00 ; 0.19 / 0.06 / 0.03 / 0.00 | 2.0e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 2 of 77 (dnf4x2@16: 0.36 vs 0.33; h2rf0@16: 0.50 vs 0.46). Of these, by more than 2 standard errors of the seed-to-seed spread: 0.

Mean log2 ratio over targets where both learn: -2.21 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 7; clearly worse: 0; of 7. Largest compute used: 3.8e-01 of a GD run.

