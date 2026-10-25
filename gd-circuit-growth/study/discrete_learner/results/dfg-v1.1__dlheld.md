## dfg-v1.1 on the dlheld suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| maj15 | 130 | 355 | -1.45 | 0.16 / 0.00 / 0.00 / 0.00 ; 0.21 / 0.12 / 0.01 / 0.00 | 1.4e-01 |
| thr30 | 158 | 528 | -1.74 | 0.18 / 0.04 / 0.02 / 0.01 ; 0.21 / 0.14 / 0.07 / 0.02 | 2.5e-01 |
| majxor | 766 | 1313 | -0.78 | 0.49 / 0.50 / 0.02 / 0.00 ; 0.47 / 0.36 / 0.16 / 0.00 | 2.1e-01 |
| majmaj5 | 816 | 2847 | -1.80 | 0.30 / 0.17 / 0.08 / 0.00 ; 0.29 / 0.22 / 0.20 / 0.03 | 2.3e-01 |
| par5 | 56 | 7245 | -7.02 | 0.00 / 0.00 / 0.00 / 0.00 ; 0.49 / 0.50 / 0.50 / 0.50 | 1.4e-01 |
| mux6 | 197 | 481 | -1.29 | 0.39 / 0.00 / 0.00 / 0.00 ; 0.37 / 0.23 / 0.00 / 0.00 | 1.4e-01 |
| stair6 | 207 | 1967 | -3.25 | 0.39 / 0.00 / 0.00 / 0.00 ; 0.38 / 0.34 / 0.26 / 0.00 | 1.5e-01 |
| inter2 | 583 | 859 | -0.56 | 0.22 / 0.13 / 0.06 / 0.00 ; 0.20 / 0.14 / 0.10 / 0.02 | 4.3e-01 |
| majpar5 | 123 | 5229 | -5.41 | 0.50 / 0.03 / 0.00 / 0.00 ; 0.47 / 0.37 / 0.18 / 0.14 | 1.4e-01 |
| hrf0 | 86 | 192 | -1.15 | 0.14 / 0.02 / 0.00 / 0.00 ; 0.15 / 0.09 / 0.06 / 0.00 | 1.4e-01 |
| hrf1 | 118 | 1203 | -3.35 | 0.36 / 0.00 / 0.00 / 0.00 ; 0.48 / 0.41 / 0.13 / 0.00 | 1.4e-01 |
| hrf2 | 46 | 107 | -1.22 | 0.06 / 0.02 / 0.00 / 0.00 ; 0.17 / 0.06 / 0.04 / 0.00 | 1.4e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 6 of 132 (majxor@64: 0.49 vs 0.47; majxor@128: 0.50 vs 0.44; majxor@256: 0.50 vs 0.36; stair6@16: 0.44 vs 0.38; inter2@16: 0.33 vs 0.30; majpar5@64: 0.50 vs 0.47). Of these, by more than 2 standard errors of the seed-to-seed spread: 5 (majxor@64, majxor@128, majxor@256, stair6@16, majpar5@64).

Mean log2 ratio over targets where both learn: -2.42 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 12; clearly worse: 0; of 12. Largest compute used: 4.3e-01 of a GD run.

