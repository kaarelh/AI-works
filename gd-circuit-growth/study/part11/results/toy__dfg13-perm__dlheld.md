## dfg13-perm on the dlheld suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| maj15 | 130 | 355 | -1.45 | 0.16 / 0.00 / 0.00 / 0.00 ; 0.21 / 0.12 / 0.01 / 0.00 | 1.5e-01 |
| thr30 | 158 | 528 | -1.74 | 0.18 / 0.04 / 0.02 / 0.01 ; 0.21 / 0.14 / 0.07 / 0.02 | 4.1e-01 |
| majxor | 225 | 1313 | -2.55 | 0.49 / 0.01 / 0.00 / 0.00 ; 0.47 / 0.36 / 0.16 / 0.00 | 2.3e-01 |
| majmaj5 | 351 | 2847 | -3.02 | 0.30 / 0.17 / 0.01 / 0.00 ; 0.29 / 0.22 / 0.20 / 0.03 | 4.2e-01 |
| par5 | 56 | 7245 | -7.02 | 0.00 / 0.00 / 0.00 / 0.00 ; 0.49 / 0.50 / 0.50 / 0.50 | 1.4e-01 |
| mux6 | 197 | 481 | -1.29 | 0.37 / 0.00 / 0.00 / 0.00 ; 0.37 / 0.23 / 0.00 / 0.00 | 1.4e-01 |
| stair6 | 207 | 1967 | -3.25 | 0.39 / 0.00 / 0.00 / 0.00 ; 0.38 / 0.34 / 0.26 / 0.00 | 1.7e-01 |
| inter2 | 441 | 859 | -0.96 | 0.22 / 0.13 / 0.04 / 0.00 ; 0.20 / 0.14 / 0.10 / 0.02 | 4.2e-01 |
| majpar5 | 128 | 5229 | -5.36 | 0.50 / 0.03 / 0.00 / 0.00 ; 0.47 / 0.37 / 0.18 / 0.14 | 1.4e-01 |
| hrf0 | 80 | 192 | -1.27 | 0.14 / 0.01 / 0.00 / 0.00 ; 0.15 / 0.09 / 0.06 / 0.00 | 1.4e-01 |
| hrf1 | 119 | 1203 | -3.34 | 0.49 / 0.00 / 0.00 / 0.00 ; 0.48 / 0.41 / 0.13 / 0.00 | 1.4e-01 |
| hrf2 | 46 | 107 | -1.23 | 0.06 / 0.00 / 0.00 / 0.00 ; 0.17 / 0.06 / 0.04 / 0.00 | 1.4e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 5 of 132 (majxor@64: 0.49 vs 0.47; majxor@128: 0.50 vs 0.44; stair6@16: 0.44 vs 0.38; inter2@16: 0.33 vs 0.30; majpar5@64: 0.50 vs 0.47). Of these, by more than 2 standard errors of the seed-to-seed spread: 4 (majxor@64, majxor@128, stair6@16, majpar5@64).

Mean log2 ratio over targets where both learn: -2.71 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 12; clearly worse: 0; of 12. Largest compute used: 4.2e-01 of a GD run.

