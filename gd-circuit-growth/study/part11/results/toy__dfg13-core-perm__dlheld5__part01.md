## dfg13-core-perm on the dlheld5 suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| h5s0 | 216 | 1454 | -2.75 | 0.34 / 0.01 / 0.01 / 0.00 ; 0.32 / 0.25 / 0.14 / 0.03 | 1.1e-01 |
| h5s1 | never | never | +nan | 0.50 / 0.50 / 0.50 / 0.50 ; 0.50 / 0.50 / 0.49 / 0.50 | 8.4e-02 |
| h5s2 | 678 | 3322 | -2.29 | 0.34 / 0.34 / 0.00 / 0.00 ; 0.45 / 0.43 / 0.41 / 0.03 | 7.9e-03 |
| h5s3 | 1752 | 8160 | -2.22 | 0.44 / 0.44 / 0.44 / 0.00 ; 0.49 / 0.49 / 0.49 / 0.39 | 1.4e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 4 of 44 (h5s0@16: 0.50 vs 0.39; h5s0@32: 0.41 vs 0.35; h5s0@128: 0.38 vs 0.29; h5s3@16: 0.53 vs 0.50). Of these, by more than 2 standard errors of the seed-to-seed spread: 0.

Mean log2 ratio over targets where both learn: -2.42 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 3; clearly worse: 0; of 4. Largest compute used: 1.4e-01 of a GD run.

