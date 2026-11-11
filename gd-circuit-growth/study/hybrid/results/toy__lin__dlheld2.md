## lin on the dlheld2 suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| thr20 | 117 | 593 | -2.34 | 0.16 / 0.06 / 0.01 / 0.00 ; 0.19 / 0.12 / 0.06 / 0.02 | 7.3e-02 |
| maj21 | 116 | 413 | -1.84 | 0.18 / 0.00 / 0.00 / 0.00 ; 0.20 / 0.12 / 0.02 / 0.00 | 7.3e-02 |
| xmaj | never | 1552 | +inf | 0.51 / 0.50 / 0.50 / 0.49 ; 0.50 / 0.49 / 0.25 / 0.00 | 7.3e-02 |
| dnf4x2 | never | 440 | +inf | 0.24 / 0.19 / 0.18 / 0.17 ; 0.26 / 0.16 / 0.01 / 0.00 | 7.3e-02 |
| sym8 | never | 504 | +inf | 0.28 / 0.28 / 0.28 / 0.28 ; 0.36 / 0.23 / 0.05 / 0.00 | 7.3e-02 |
| h2rf0 | never | 527 | +inf | 0.37 / 0.33 / 0.29 / 0.27 ; 0.38 / 0.24 / 0.02 / 0.00 | 7.3e-02 |
| h2rf1 | 103 | 127 | -0.29 | 0.15 / 0.04 / 0.03 / 0.03 ; 0.19 / 0.06 / 0.03 / 0.00 | 7.3e-02 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 33 of 77 (thr20@32: 0.31 vs 0.27; xmaj@512: 0.50 vs 0.47; xmaj@1024: 0.50 vs 0.25; xmaj@2048: 0.51 vs 0.00; xmaj@4096: 0.49 vs 0.00; xmaj@8192: 0.50 vs 0.00; xmaj@16384: 0.50 vs 0.00; dnf4x2@256: 0.19 vs 0.16; dnf4x2@512: 0.18 vs 0.08; dnf4x2@1024: 0.18 vs 0.01; dnf4x2@2048: 0.17 vs 0.00; dnf4x2@4096: 0.17 vs 0.00; dnf4x2@8192: 0.17 vs 0.00; dnf4x2@16384: 0.17 vs 0.00; sym8@256: 0.28 vs 0.23; sym8@512: 0.28 vs 0.10; sym8@1024: 0.28 vs 0.05; sym8@2048: 0.28 vs 0.01; sym8@4096: 0.28 vs 0.00; sym8@8192: 0.28 vs 0.00; sym8@16384: 0.28 vs 0.00; h2rf0@32: 0.48 vs 0.42; h2rf0@128: 0.35 vs 0.31; h2rf0@256: 0.33 vs 0.24; h2rf0@512: 0.30 vs 0.10; h2rf0@1024: 0.29 vs 0.02; h2rf0@2048: 0.27 vs 0.00; h2rf0@4096: 0.27 vs 0.00; h2rf0@8192: 0.28 vs 0.00; h2rf0@16384: 0.27 vs 0.00; h2rf1@4096: 0.03 vs 0.00; h2rf1@8192: 0.03 vs 0.00; h2rf1@16384: 0.03 vs 0.00). Of these, by more than 2 standard errors of the seed-to-seed spread: 29 (xmaj@512, xmaj@1024, xmaj@2048, xmaj@4096, xmaj@8192, xmaj@16384, dnf4x2@256, dnf4x2@512, dnf4x2@1024, dnf4x2@2048, dnf4x2@4096, dnf4x2@8192, dnf4x2@16384, sym8@512, sym8@1024, sym8@2048, sym8@4096, sym8@8192, sym8@16384, h2rf0@256, h2rf0@512, h2rf0@1024, h2rf0@2048, h2rf0@4096, h2rf0@8192, h2rf0@16384, h2rf1@4096, h2rf1@8192, h2rf1@16384).

Mean log2 ratio over targets where both learn: -1.49 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 3; clearly worse: 4; of 7. Largest compute used: 7.3e-02 of a GD run.

