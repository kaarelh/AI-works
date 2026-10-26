## hyb_portfolio on the dlheld suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| maj15 | 119 | 355 | -1.58 | 0.17 / 0.02 / 0.00 / 0.00 ; 0.21 / 0.12 / 0.01 / 0.00 | 1.9e-01 |
| thr30 | 144 | 528 | -1.87 | 0.17 / 0.05 / 0.02 / 0.01 ; 0.21 / 0.14 / 0.07 / 0.02 | 3.6e-01 |
| majxor | 769 | 1313 | -0.77 | 0.47 / 0.43 / 0.02 / 0.00 ; 0.47 / 0.36 / 0.16 / 0.00 | 4.5e-01 |
| majmaj5 | 1156 | 2847 | -1.30 | 0.25 / 0.18 / 0.12 / 0.00 ; 0.29 / 0.22 / 0.20 / 0.03 | 7.6e-01 |
| par5 | 539 | 7245 | -3.75 | 0.18 / 0.33 / 0.00 / 0.00 ; 0.49 / 0.50 / 0.50 / 0.50 | 1.9e-01 |
| mux6 | 124 | 481 | -1.96 | 0.34 / 0.00 / 0.00 / 0.00 ; 0.37 / 0.23 / 0.00 / 0.00 | 1.9e-01 |
| stair6 | 179 | 1967 | -3.46 | 0.34 / 0.00 / 0.00 / 0.00 ; 0.38 / 0.34 / 0.26 / 0.00 | 2.1e-01 |
| inter2 | 417 | 859 | -1.04 | 0.20 / 0.12 / 0.05 / 0.00 ; 0.20 / 0.14 / 0.10 / 0.02 | 7.2e-01 |
| majpar5 | 126 | 5229 | -5.37 | 0.44 / 0.03 / 0.00 / 0.00 ; 0.47 / 0.37 / 0.18 / 0.14 | 1.9e-01 |
| hrf0 | 50 | 192 | -1.95 | 0.08 / 0.00 / 0.00 / 0.00 ; 0.15 / 0.09 / 0.06 / 0.00 | 2.0e-01 |
| hrf1 | 118 | 1203 | -3.36 | 0.36 / 0.00 / 0.00 / 0.00 ; 0.48 / 0.41 / 0.13 / 0.00 | 1.9e-01 |
| hrf2 | 72 | 107 | -0.57 | 0.11 / 0.02 / 0.00 / 0.00 ; 0.17 / 0.06 / 0.04 / 0.00 | 1.9e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 3 of 132 (majxor@128: 0.48 vs 0.44; majxor@256: 0.43 vs 0.36; majmaj5@16: 0.46 vs 0.44). Of these, by more than 2 standard errors of the seed-to-seed spread: 2 (majxor@128, majxor@256).

Mean log2 ratio over targets where both learn: -2.25 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 12; clearly worse: 0; of 12. Largest compute used: 7.6e-01 of a GD run.

