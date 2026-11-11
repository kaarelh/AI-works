## dfg-c1.0 on the dlheld suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| maj15 | 132 | 355 | -1.42 | 0.16 / 0.05 / 0.01 / 0.00 ; 0.21 / 0.12 / 0.01 / 0.00 | 1.4e-01 |
| thr30 | 191 | 528 | -1.46 | 0.18 / 0.08 / 0.06 / 0.06 ; 0.21 / 0.14 / 0.07 / 0.02 | 2.1e-01 |
| majxor | 782 | 1313 | -0.75 | 0.49 / 0.50 / 0.03 / 0.01 ; 0.47 / 0.36 / 0.16 / 0.00 | 1.5e-01 |
| majmaj5 | 891 | 2847 | -1.68 | 0.30 / 0.18 / 0.09 / 0.00 ; 0.29 / 0.22 / 0.20 / 0.03 | 1.6e-01 |
| par5 | 56 | 7245 | -7.02 | 0.00 / 0.00 / 0.00 / 0.00 ; 0.49 / 0.50 / 0.50 / 0.50 | 1.4e-01 |
| mux6 | 197 | 481 | -1.29 | 0.39 / 0.00 / 0.00 / 0.00 ; 0.37 / 0.23 / 0.00 / 0.00 | 1.4e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 7 of 66 (thr30@2048: 0.07 vs 0.03; thr30@4096: 0.06 vs 0.02; thr30@8192: 0.06 vs 0.01; thr30@16384: 0.05 vs 0.01; majxor@64: 0.49 vs 0.47; majxor@128: 0.50 vs 0.44; majxor@256: 0.50 vs 0.36). Of these, by more than 2 standard errors of the seed-to-seed spread: 7 (thr30@2048, thr30@4096, thr30@8192, thr30@16384, majxor@64, majxor@128, majxor@256).

Mean log2 ratio over targets where both learn: -2.27 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 6; clearly worse: 0; of 6. Largest compute used: 2.1e-01 of a GD run.

