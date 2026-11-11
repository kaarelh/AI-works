## abl-no-background-no-small-n-perm on the designed suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| maj9 | 107 | 263 | -1.30 | 0.15 / 0.00 / 0.00 / 0.00 ; 0.20 / 0.10 / 0.00 / 0.00 | 3.7e-01 |
| thr10 | 146 | 563 | -1.95 | 0.18 / 0.06 / 0.01 / 0.00 ; 0.22 / 0.12 / 0.06 / 0.02 | 3.4e-01 |
| par4 | 52 | 2728 | -5.71 | 0.00 / 0.00 / 0.00 / 0.00 ; 0.50 / 0.50 / 0.49 / 0.00 | 1.4e-01 |
| stair5 | 112 | 1514 | -3.76 | 0.51 / 0.00 / 0.00 / 0.00 ; 0.45 / 0.36 / 0.23 / 0.00 | 1.4e-01 |
| mux | 110 | 1156 | -3.39 | 0.41 / 0.01 / 0.00 / 0.00 ; 0.43 / 0.35 / 0.12 / 0.00 | 1.4e-01 |
| rmaj9 | 167 | 2027 | -3.60 | 0.26 / 0.00 / 0.00 / 0.00 ; 0.25 / 0.20 / 0.16 / 0.00 | 1.7e-01 |
| sparsepoly | 107 | 2205 | -4.36 | 0.12 / 0.00 / 0.00 / 0.00 ; 0.24 / 0.15 / 0.13 / 0.00 | 1.4e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 12 of 77 (maj9@16: 0.49 vs 0.35; maj9@32: 0.49 vs 0.27; thr10@16: 0.50 vs 0.39; thr10@32: 0.50 vs 0.30; stair5@16: 0.50 vs 0.46; stair5@32: 0.50 vs 0.47; stair5@64: 0.51 vs 0.45; mux@16: 0.50 vs 0.46; mux@32: 0.50 vs 0.46; rmaj9@16: 0.50 vs 0.40; rmaj9@32: 0.50 vs 0.32; sparsepoly@16: 0.39 vs 0.35). Of these, by more than 2 standard errors of the seed-to-seed spread: 10 (maj9@16, maj9@32, thr10@16, thr10@32, stair5@64, mux@16, mux@32, rmaj9@16, rmaj9@32, sparsepoly@16).

Mean log2 ratio over targets where both learn: -3.44 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 7; clearly worse: 0; of 7. Largest compute used: 3.7e-01 of a GD run.

