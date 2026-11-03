## dfg13-core-perm on the dlheld5 suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| h5s4 | 178 | 2744 | -3.94 | 0.19 / 0.00 / 0.00 / 0.00 ; 0.28 / 0.21 / 0.20 / 0.02 | 7.7e-03 |
| h5s5 | 449 | 13832 | -4.95 | 0.49 / 0.50 / 0.00 / 0.00 ; 0.40 / 0.38 / 0.37 / 0.37 | 1.5e-01 |
| h5s6 | 354 | 6227 | -4.14 | 0.36 / 0.19 / 0.00 / 0.00 ; 0.44 / 0.44 / 0.42 / 0.24 | 4.0e-02 |
| h5s7 | 1698 | 13863 | -3.03 | 0.37 / 0.37 / 0.37 / 0.37 ; 0.43 / 0.44 / 0.44 / 0.45 | 6.9e-02 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 4 of 44 (h5s5@32: 0.50 vs 0.43; h5s5@64: 0.49 vs 0.40; h5s5@128: 0.50 vs 0.37; h5s5@256: 0.50 vs 0.38). Of these, by more than 2 standard errors of the seed-to-seed spread: 4 (h5s5@32, h5s5@64, h5s5@128, h5s5@256).

Mean log2 ratio over targets where both learn: -4.01 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 4; clearly worse: 0; of 4. Largest compute used: 1.5e-01 of a GD run.

