## p10_sum-perm on the dlheld suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| maj15 | 105 | 355 | -1.76 | 0.17 / 0.00 / 0.00 / 0.00 ; 0.21 / 0.12 / 0.01 / 0.00 | 2.0e-01 |
| thr30 | 149 | 528 | -1.83 | 0.17 / 0.05 / 0.02 / 0.01 ; 0.21 / 0.14 / 0.07 / 0.02 | 5.8e-01 |
| majxor | 224 | 1313 | -2.55 | 0.47 / 0.01 / 0.00 / 0.00 ; 0.47 / 0.36 / 0.16 / 0.00 | 4.1e-01 |
| majmaj5 | 360 | 2847 | -2.98 | 0.26 / 0.17 / 0.00 / 0.00 ; 0.29 / 0.22 / 0.20 / 0.03 | 5.8e-01 |
| par5 | 839 | 7245 | -3.11 | 0.36 / 0.17 / 0.00 / 0.00 ; 0.49 / 0.50 / 0.50 / 0.50 | 1.9e-01 |
| mux6 | 123 | 481 | -1.96 | 0.32 / 0.00 / 0.00 / 0.00 ; 0.37 / 0.23 / 0.00 / 0.00 | 1.9e-01 |
| stair6 | 190 | 1967 | -3.37 | 0.35 / 0.00 / 0.00 / 0.00 ; 0.38 / 0.34 / 0.26 / 0.00 | 2.4e-01 |
| inter2 | 346 | 859 | -1.31 | 0.19 / 0.12 / 0.03 / 0.00 ; 0.20 / 0.14 / 0.10 / 0.02 | 7.0e-01 |
| majpar5 | 127 | 5229 | -5.37 | 0.42 / 0.03 / 0.00 / 0.00 ; 0.47 / 0.37 / 0.18 / 0.14 | 2.0e-01 |
| hrf0 | 62 | 192 | -1.63 | 0.10 / 0.01 / 0.00 / 0.00 ; 0.15 / 0.09 / 0.06 / 0.00 | 2.1e-01 |
| hrf1 | 116 | 1203 | -3.38 | 0.37 / 0.00 / 0.00 / 0.00 ; 0.48 / 0.41 / 0.13 / 0.00 | 1.9e-01 |
| hrf2 | 54 | 107 | -1.00 | 0.08 / 0.00 / 0.00 / 0.00 ; 0.17 / 0.06 / 0.04 / 0.00 | 2.0e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 6 of 132 (majxor@128: 0.48 vs 0.44; majmaj5@16: 0.47 vs 0.44; majmaj5@32: 0.35 vs 0.32; inter2@16: 0.34 vs 0.30; inter2@32: 0.31 vs 0.27; hrf2@16: 0.38 vs 0.35). Of these, by more than 2 standard errors of the seed-to-seed spread: 1 (majxor@128).

Mean log2 ratio over targets where both learn: -2.52 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 12; clearly worse: 0; of 12. Largest compute used: 7.0e-01 of a GD run.

