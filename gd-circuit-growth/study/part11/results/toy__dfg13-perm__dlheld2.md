## dfg13-perm on the dlheld2 suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| thr20 | 138 | 593 | -2.11 | 0.17 / 0.06 / 0.02 / 0.01 ; 0.19 / 0.12 / 0.06 / 0.02 | 3.1e-01 |
| maj21 | 112 | 413 | -1.88 | 0.20 / 0.00 / 0.00 / 0.00 ; 0.20 / 0.12 / 0.02 / 0.00 | 1.4e-01 |
| xmaj | 61 | 1552 | -4.66 | 0.07 / 0.00 / 0.00 / 0.00 ; 0.50 / 0.49 / 0.25 / 0.00 | 1.4e-01 |
| dnf4x2 | 235 | 440 | -0.91 | 0.28 / 0.08 / 0.00 / 0.00 ; 0.26 / 0.16 / 0.01 / 0.00 | 2.8e-01 |
| sym8 | 54 | 504 | -3.23 | 0.00 / 0.01 / 0.00 / 0.00 ; 0.36 / 0.23 / 0.05 / 0.00 | 1.6e-01 |
| h2rf0 | 119 | 527 | -2.15 | 0.30 / 0.03 / 0.00 / 0.00 ; 0.38 / 0.24 / 0.02 / 0.00 | 1.7e-01 |
| h2rf1 | 82 | 127 | -0.63 | 0.14 / 0.02 / 0.00 / 0.00 ; 0.19 / 0.06 / 0.03 / 0.00 | 1.5e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 5 of 77 (thr20@32: 0.29 vs 0.27; dnf4x2@16: 0.36 vs 0.33; dnf4x2@64: 0.28 vs 0.26; sym8@16: 0.38 vs 0.31; sym8@32: 0.40 vs 0.34). Of these, by more than 2 standard errors of the seed-to-seed spread: 2 (dnf4x2@64, sym8@32).

Mean log2 ratio over targets where both learn: -2.22 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 7; clearly worse: 0; of 7. Largest compute used: 3.1e-01 of a GD run.

