## abl-coef-readout-perm on the designed suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| maj9 | 309 | 263 | +0.23 | 0.21 / 0.12 / 0.00 / 0.00 ; 0.20 / 0.10 / 0.00 / 0.00 | 1.9e-01 |
| thr10 | 295 | 563 | -0.93 | 0.23 / 0.11 / 0.04 / 0.00 ; 0.22 / 0.12 / 0.06 / 0.02 | 1.9e-01 |
| par4 | 52 | 2728 | -5.72 | 0.00 / 0.00 / 0.00 / 0.00 ; 0.50 / 0.50 / 0.49 / 0.00 | 1.4e-01 |
| stair5 | 112 | 1514 | -3.75 | 0.44 / 0.01 / 0.00 / 0.00 ; 0.45 / 0.36 / 0.23 / 0.00 | 1.4e-01 |
| mux | 63 | 1156 | -4.20 | 0.09 / 0.02 / 0.00 / 0.00 ; 0.43 / 0.35 / 0.12 / 0.00 | 1.4e-01 |
| rmaj9 | 210 | 2027 | -3.27 | 0.23 / 0.06 / 0.00 / 0.00 ; 0.25 / 0.20 / 0.16 / 0.00 | 1.5e-01 |
| sparsepoly | 99 | 2205 | -4.48 | 0.16 / 0.04 / 0.00 / 0.00 ; 0.24 / 0.15 / 0.13 / 0.00 | 1.4e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 2 of 77 (maj9@128: 0.16 vs 0.13; maj9@256: 0.12 vs 0.10). Of these, by more than 2 standard errors of the seed-to-seed spread: 1 (maj9@128).

Mean log2 ratio over targets where both learn: -3.16 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 6; clearly worse: 0; of 7. Largest compute used: 1.9e-01 of a GD run.

