## dfg13-core-perm on the designed suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| thr10 | 154 | 563 | -1.87 | 0.43 / 0.06 / 0.02 / 0.01 ; 0.22 / 0.12 / 0.06 / 0.02 | 1.2e-01 |
| par2 | 16 | 200 | -3.64 | 0.00 / 0.00 / 0.00 / 0.00 ; 0.45 / 0.00 / 0.00 / 0.00 | 5.5e-03 |
| par3 | 28 | 843 | -4.91 | 0.00 / 0.00 / 0.00 / 0.00 ; 0.50 / 0.48 / 0.00 / 0.00 | 5.5e-03 |
| par4 | 3124 | 2728 | +0.20 | 0.49 / 0.50 / 0.51 / 0.00 ; 0.50 / 0.50 / 0.49 / 0.00 | 1.5e-02 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 5 of 44 (thr10@16: 0.50 vs 0.39; thr10@32: 0.50 vs 0.30; thr10@64: 0.43 vs 0.22; par3@16: 0.52 vs 0.50; par4@2048: 0.26 vs 0.17). Of these, by more than 2 standard errors of the seed-to-seed spread: 4 (thr10@16, thr10@32, thr10@64, par3@16).

Mean log2 ratio over targets where both learn: -2.56 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 3; clearly worse: 0; of 4. Largest compute used: 1.2e-01 of a GD run.

