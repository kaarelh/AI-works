## dfg13-core-perm on the dlheld2 suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| thr20 | 455 | 593 | -0.38 | 0.29 / 0.17 / 0.06 / 0.03 ; 0.19 / 0.12 / 0.06 / 0.02 | 8.0e-02 |
| maj21 | 174 | 413 | -1.25 | 0.49 / 0.00 / 0.00 / 0.00 ; 0.20 / 0.12 / 0.02 / 0.00 | 7.0e-03 |
| xmaj | 56 | 1552 | -4.80 | 0.00 / 0.00 / 0.00 / 0.00 ; 0.50 / 0.49 / 0.25 / 0.00 | 7.2e-03 |
| dnf4x2 | 252 | 440 | -0.80 | 0.30 / 0.10 / 0.00 / 0.00 ; 0.26 / 0.16 / 0.01 / 0.00 | 1.2e-02 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 13 of 44 (thr20@16: 0.51 vs 0.31; thr20@32: 0.41 vs 0.27; thr20@64: 0.29 vs 0.19; thr20@128: 0.26 vs 0.15; thr20@256: 0.17 vs 0.12; thr20@16384: 0.03 vs 0.01; maj21@16: 0.49 vs 0.37; maj21@32: 0.49 vs 0.27; maj21@64: 0.49 vs 0.20; maj21@128: 0.18 vs 0.14; dnf4x2@16: 0.50 vs 0.33; dnf4x2@64: 0.30 vs 0.26; dnf4x2@128: 0.31 vs 0.21). Of these, by more than 2 standard errors of the seed-to-seed spread: 9 (thr20@16, thr20@64, thr20@128, thr20@16384, maj21@16, maj21@32, maj21@64, dnf4x2@64, dnf4x2@128).

Mean log2 ratio over targets where both learn: -1.81 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 4; clearly worse: 0; of 4. Largest compute used: 8.0e-02 of a GD run.

