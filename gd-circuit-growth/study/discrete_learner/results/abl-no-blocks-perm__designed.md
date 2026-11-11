## abl-no-blocks-perm on the designed suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| maj9 | 168 | 263 | -0.64 | 0.21 / 0.02 / 0.00 / 0.00 ; 0.20 / 0.10 / 0.00 / 0.00 | 3.7e-01 |
| thr10 | 144 | 563 | -1.96 | 0.22 / 0.08 / 0.01 / 0.00 ; 0.22 / 0.12 / 0.06 / 0.02 | 3.4e-01 |
| par4 | 52 | 2728 | -5.72 | 0.00 / 0.00 / 0.00 / 0.00 ; 0.50 / 0.50 / 0.49 / 0.00 | 1.4e-01 |
| stair5 | 111 | 1514 | -3.77 | 0.44 / 0.01 / 0.00 / 0.00 ; 0.45 / 0.36 / 0.23 / 0.00 | 1.4e-01 |
| mux | 61 | 1156 | -4.24 | 0.08 / 0.00 / 0.00 / 0.00 ; 0.43 / 0.35 / 0.12 / 0.00 | 1.4e-01 |
| rmaj9 | 178 | 2027 | -3.51 | 0.24 / 0.00 / 0.00 / 0.00 ; 0.25 / 0.20 / 0.16 / 0.00 | 1.7e-01 |
| sparsepoly | 80 | 2205 | -4.78 | 0.14 / 0.01 / 0.00 / 0.00 ; 0.24 / 0.15 / 0.13 / 0.00 | 1.4e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 1 of 77 (maj9@128: 0.15 vs 0.13). Of these, by more than 2 standard errors of the seed-to-seed spread: 0.

Mean log2 ratio over targets where both learn: -3.52 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 7; clearly worse: 0; of 7. Largest compute used: 3.7e-01 of a GD run.

