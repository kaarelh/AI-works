## dfg13-core-perm on the dlheld2 suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| sym8 | 100 | 504 | -2.33 | 0.28 / 0.00 / 0.00 / 0.00 ; 0.36 / 0.23 / 0.05 / 0.00 | 7.2e-03 |
| h2rf0 | 112 | 527 | -2.24 | 0.28 / 0.05 / 0.00 / 0.00 ; 0.38 / 0.24 / 0.02 / 0.00 | 1.5e-02 |
| h2rf1 | 80 | 127 | -0.67 | 0.13 / 0.01 / 0.00 / 0.00 ; 0.19 / 0.06 / 0.03 / 0.00 | 1.7e-02 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 2 of 33 (h2rf0@32: 0.46 vs 0.42; h2rf1@16: 0.50 vs 0.36). Of these, by more than 2 standard errors of the seed-to-seed spread: 1 (h2rf0@32).

Mean log2 ratio over targets where both learn: -1.75 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 3; clearly worse: 0; of 3. Largest compute used: 1.7e-02 of a GD run.

