## hyb_portfolio-s3 on the designed suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| rmaj9 | 164 | 2027 | -3.63 | 0.24 / 0.00 / 0.00 / 0.00 ; 0.25 / 0.20 / 0.16 / 0.00 | 2.5e-01 |
| andxor | 34 | 376 | -3.48 | 0.03 / 0.00 / 0.00 / 0.00 ; 0.33 / 0.19 / 0.00 / 0.00 | 1.9e-01 |
| sparsepoly | 86 | 2205 | -4.68 | 0.13 / 0.01 / 0.00 / 0.00 ; 0.24 / 0.15 / 0.13 / 0.00 | 1.9e-01 |
| rand0 | 16 | 222 | -3.80 | 0.04 / 0.02 / 0.00 / 0.00 ; 0.43 / 0.05 / 0.00 / 0.00 | 2.0e-01 |
| rand1 | 91 | 463 | -2.34 | 0.21 / 0.00 / 0.00 / 0.00 ; 0.31 / 0.18 / 0.00 / 0.00 | 1.9e-01 |
| rand2 | 22 | 91 | -2.04 | 0.06 / 0.02 / 0.00 / 0.00 ; 0.13 / 0.06 / 0.03 / 0.00 | 2.0e-01 |
| rand3 | 195 | 1016 | -2.38 | 0.38 / 0.07 / 0.00 / 0.00 ; 0.44 / 0.32 / 0.10 / 0.00 | 2.0e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 2 of 77 (rmaj9@32: 0.35 vs 0.32; rand1@16: 0.42 vs 0.39). Of these, by more than 2 standard errors of the seed-to-seed spread: 0.

Mean log2 ratio over targets where both learn: -3.19 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 7; clearly worse: 0; of 7. Largest compute used: 2.5e-01 of a GD run.

