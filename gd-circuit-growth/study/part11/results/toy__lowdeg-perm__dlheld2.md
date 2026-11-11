## lowdeg-perm on the dlheld2 suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| thr20 | 1054 | 593 | +0.83 | 0.31 / 0.23 / 0.10 / 0.06 ; 0.19 / 0.12 / 0.06 / 0.02 | 8.9e-02 |
| maj21 | 693 | 413 | +0.74 | 0.47 / 0.33 / 0.04 / 0.01 ; 0.20 / 0.12 / 0.02 / 0.00 | 8.9e-02 |
| xmaj | 168 | 1552 | -3.20 | 0.25 / 0.00 / 0.00 / 0.00 ; 0.50 / 0.49 / 0.25 / 0.00 | 8.9e-02 |
| dnf4x2 | 467 | 440 | +0.09 | 0.37 / 0.23 / 0.00 / 0.01 ; 0.26 / 0.16 / 0.01 / 0.00 | 8.9e-02 |
| sym8 | 1553 | 504 | +1.62 | 0.28 / 0.28 / 0.16 / 0.04 ; 0.36 / 0.23 / 0.05 / 0.00 | 8.9e-02 |
| h2rf0 | 118 | 527 | -2.16 | 0.35 / 0.07 / 0.07 / 0.02 ; 0.38 / 0.24 / 0.02 / 0.00 | 8.9e-02 |
| h2rf1 | 179 | 127 | +0.50 | 0.13 / 0.06 / 0.03 / 0.03 ; 0.19 / 0.06 / 0.03 / 0.00 | 8.9e-02 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 35 of 77 (thr20@16: 0.51 vs 0.31; thr20@32: 0.48 vs 0.27; thr20@64: 0.31 vs 0.19; thr20@128: 0.26 vs 0.15; thr20@256: 0.23 vs 0.12; thr20@512: 0.18 vs 0.11; thr20@1024: 0.10 vs 0.06; thr20@2048: 0.07 vs 0.03; thr20@4096: 0.06 vs 0.02; thr20@8192: 0.06 vs 0.01; thr20@16384: 0.06 vs 0.01; maj21@16: 0.50 vs 0.37; maj21@32: 0.46 vs 0.27; maj21@64: 0.47 vs 0.20; maj21@128: 0.44 vs 0.14; maj21@256: 0.33 vs 0.12; maj21@512: 0.15 vs 0.09; dnf4x2@16: 0.44 vs 0.33; dnf4x2@32: 0.37 vs 0.33; dnf4x2@64: 0.37 vs 0.26; dnf4x2@128: 0.31 vs 0.21; dnf4x2@256: 0.23 vs 0.16; dnf4x2@2048: 0.02 vs 0.00; sym8@256: 0.28 vs 0.23; sym8@512: 0.27 vs 0.10; sym8@1024: 0.16 vs 0.05; sym8@2048: 0.06 vs 0.01; sym8@4096: 0.04 vs 0.00; h2rf0@16: 0.49 vs 0.46; h2rf0@32: 0.49 vs 0.42; h2rf0@1024: 0.07 vs 0.02; h2rf0@2048: 0.07 vs 0.00; h2rf0@4096: 0.02 vs 0.00; h2rf1@128: 0.13 vs 0.10; h2rf1@4096: 0.03 vs 0.00). Of these, by more than 2 standard errors of the seed-to-seed spread: 31 (thr20@16, thr20@32, thr20@64, thr20@128, thr20@256, thr20@512, thr20@1024, thr20@2048, thr20@4096, thr20@8192, thr20@16384, maj21@16, maj21@32, maj21@64, maj21@128, maj21@256, maj21@512, dnf4x2@64, dnf4x2@128, dnf4x2@256, dnf4x2@2048, sym8@512, sym8@1024, sym8@2048, sym8@4096, h2rf0@32, h2rf0@1024, h2rf0@2048, h2rf0@4096, h2rf1@128, h2rf1@4096).

Mean log2 ratio over targets where both learn: -0.23 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 2; clearly worse: 4; of 7. Largest compute used: 8.9e-02 of a GD run.

