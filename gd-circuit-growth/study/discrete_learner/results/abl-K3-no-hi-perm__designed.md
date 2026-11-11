## abl-K3-no-hi-perm on the designed suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| maj9 | 107 | 263 | -1.30 | 0.15 / 0.00 / 0.00 / 0.00 ; 0.20 / 0.10 / 0.00 / 0.00 | 2.5e-01 |
| thr10 | 152 | 563 | -1.89 | 0.18 / 0.07 / 0.01 / 0.00 ; 0.22 / 0.12 / 0.06 / 0.02 | 2.1e-01 |
| par4 | never | 2728 | +inf | 0.50 / 0.51 / 0.50 / 0.50 ; 0.50 / 0.50 / 0.49 / 0.00 | 5.5e-03 |
| stair5 | 113 | 1514 | -3.75 | 0.44 / 0.00 / 0.00 / 0.00 ; 0.45 / 0.36 / 0.23 / 0.00 | 1.4e-02 |
| mux | 158 | 1156 | -2.87 | 0.27 / 0.01 / 0.01 / 0.00 ; 0.43 / 0.35 / 0.12 / 0.00 | 5.8e-03 |
| rmaj9 | 167 | 2027 | -3.60 | 0.26 / 0.00 / 0.00 / 0.00 ; 0.25 / 0.20 / 0.16 / 0.00 | 3.8e-02 |
| sparsepoly | 93 | 2205 | -4.56 | 0.14 / 0.01 / 0.00 / 0.00 ; 0.24 / 0.15 / 0.13 / 0.00 | 5.6e-03 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 4 of 77 (par4@2048: 0.50 vs 0.17; par4@4096: 0.50 vs 0.00; par4@8192: 0.50 vs 0.00; par4@16384: 0.50 vs 0.00). Of these, by more than 2 standard errors of the seed-to-seed spread: 4 (par4@2048, par4@4096, par4@8192, par4@16384).

Mean log2 ratio over targets where both learn: -3.00 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 6; clearly worse: 1; of 7. Largest compute used: 2.5e-01 of a GD run.

