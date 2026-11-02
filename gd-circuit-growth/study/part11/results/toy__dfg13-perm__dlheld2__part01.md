## dfg13-perm on the dlheld2 suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| thr20 | 138 | 593 | -2.11 | 0.17 / 0.06 / 0.02 / 0.01 ; 0.19 / 0.12 / 0.06 / 0.02 | 3.1e-01 |
| maj21 | 112 | 413 | -1.88 | 0.20 / 0.00 / 0.00 / 0.00 ; 0.20 / 0.12 / 0.02 / 0.00 | 1.4e-01 |
| xmaj | 61 | 1552 | -4.66 | 0.07 / 0.00 / 0.00 / 0.00 ; 0.50 / 0.49 / 0.25 / 0.00 | 1.4e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 1 of 33 (thr20@32: 0.29 vs 0.27). Of these, by more than 2 standard errors of the seed-to-seed spread: 0.

Mean log2 ratio over targets where both learn: -2.88 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 3; clearly worse: 0; of 3. Largest compute used: 3.1e-01 of a GD run.

