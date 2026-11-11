## dfg13-strict-perm on the dlsymdev suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| sym7 | 56 | 670 | -3.59 | 0.00 / 0.00 / 0.00 / 0.00 ; 0.48 / 0.32 / 0.02 / 0.00 | 1.5e-01 |
| ex3of8 | 102 | 1355 | -3.73 | 0.31 / 0.00 / 0.00 / 0.00 ; 0.29 / 0.27 / 0.17 / 0.00 | 1.6e-01 |
| band11 | 775 | 3253 | -2.07 | 0.50 / 0.50 / 0.00 / 0.00 ; 0.50 / 0.50 / 0.47 / 0.01 | 1.4e-01 |
| far9 | 93 | 392 | -2.07 | 0.22 / 0.00 / 0.00 / 0.00 ; 0.23 / 0.14 / 0.05 / 0.00 | 1.5e-01 |
| ssym9 | 111 | 821 | -2.89 | 0.49 / 0.00 / 0.00 / 0.00 ; 0.47 / 0.33 / 0.05 / 0.00 | 1.6e-01 |
| symxpar | 112 | 2176 | -4.28 | 0.51 / 0.00 / 0.00 / 0.00 ; 0.49 / 0.41 / 0.28 / 0.00 | 1.4e-01 |
| twosym | 388 | 3389 | -3.13 | 0.50 / 0.25 / 0.00 / 0.00 ; 0.49 / 0.49 / 0.45 / 0.01 | 1.6e-01 |
| thrsum | 113 | 515 | -2.19 | 0.28 / 0.00 / 0.00 / 0.00 ; 0.42 / 0.19 / 0.05 / 0.00 | 1.5e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 6 of 88 (sym7@16: 0.50 vs 0.48; ex3of8@16: 0.32 vs 0.24; ex3of8@32: 0.33 vs 0.28; far9@16: 0.37 vs 0.26; far9@32: 0.26 vs 0.23; symxpar@64: 0.51 vs 0.49). Of these, by more than 2 standard errors of the seed-to-seed spread: 3 (ex3of8@32, far9@16, symxpar@64).

Mean log2 ratio over targets where both learn: -2.99 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 8; clearly worse: 0; of 8. Largest compute used: 1.6e-01 of a GD run.

