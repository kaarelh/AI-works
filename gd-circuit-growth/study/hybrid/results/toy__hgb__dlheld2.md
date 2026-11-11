## hgb on the dlheld2 suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| thr20 | 1262 | 593 | +1.09 | 0.21 / 0.14 / 0.11 / 0.07 ; 0.19 / 0.12 / 0.06 / 0.02 | 3.0e-03 |
| maj21 | 1956 | 413 | +2.24 | 0.28 / 0.17 / 0.12 / 0.08 ; 0.20 / 0.12 / 0.02 / 0.00 | 3.0e-03 |
| xmaj | 1538 | 1552 | -0.01 | 0.50 / 0.48 / 0.24 / 0.03 ; 0.50 / 0.49 / 0.25 / 0.00 | 3.0e-03 |
| dnf4x2 | 98 | 440 | -2.16 | 0.24 / 0.00 / 0.00 / 0.00 ; 0.26 / 0.16 / 0.01 / 0.00 | 3.0e-03 |
| sym8 | 2689 | 504 | +2.42 | 0.33 / 0.30 / 0.18 / 0.07 ; 0.36 / 0.23 / 0.05 / 0.00 | 3.0e-03 |
| h2rf0 | 220 | 527 | -1.26 | 0.34 / 0.07 / 0.00 / 0.00 ; 0.38 / 0.24 / 0.02 / 0.00 | 3.0e-03 |
| h2rf1 | 58 | 127 | -1.13 | 0.04 / 0.03 / 0.00 / 0.00 ; 0.19 / 0.06 / 0.03 / 0.00 | 3.0e-03 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 31 of 77 (thr20@16: 0.51 vs 0.31; thr20@32: 0.50 vs 0.27; thr20@256: 0.14 vs 0.12; thr20@1024: 0.11 vs 0.06; thr20@2048: 0.09 vs 0.03; thr20@4096: 0.07 vs 0.02; thr20@8192: 0.05 vs 0.01; thr20@16384: 0.05 vs 0.01; maj21@16: 0.50 vs 0.37; maj21@32: 0.50 vs 0.27; maj21@64: 0.28 vs 0.20; maj21@128: 0.20 vs 0.14; maj21@256: 0.17 vs 0.12; maj21@512: 0.15 vs 0.09; maj21@1024: 0.12 vs 0.02; maj21@2048: 0.10 vs 0.00; maj21@4096: 0.08 vs 0.00; maj21@8192: 0.06 vs 0.00; maj21@16384: 0.04 vs 0.00; xmaj@4096: 0.03 vs 0.00; xmaj@8192: 0.05 vs 0.00; dnf4x2@16: 0.44 vs 0.33; sym8@256: 0.30 vs 0.23; sym8@512: 0.25 vs 0.10; sym8@1024: 0.18 vs 0.05; sym8@2048: 0.12 vs 0.01; sym8@4096: 0.07 vs 0.00; h2rf0@16: 0.49 vs 0.46; h2rf0@32: 0.49 vs 0.42; h2rf1@16: 0.46 vs 0.36; h2rf1@32: 0.46 vs 0.27). Of these, by more than 2 standard errors of the seed-to-seed spread: 25 (thr20@16, thr20@32, thr20@256, thr20@1024, thr20@2048, thr20@4096, thr20@8192, thr20@16384, maj21@16, maj21@32, maj21@64, maj21@128, maj21@256, maj21@512, maj21@1024, maj21@2048, maj21@4096, maj21@8192, maj21@16384, sym8@512, sym8@1024, sym8@2048, sym8@4096, h2rf0@32, h2rf1@32).

Mean log2 ratio over targets where both learn: +0.17 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 3; clearly worse: 3; of 7. Largest compute used: 3.0e-03 of a GD run.

