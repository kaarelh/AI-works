## dfg13-nosmalln-perm on the dlsymdev suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| sym7 | 111 | 670 | -2.59 | 0.48 / 0.00 / 0.00 / 0.00 ; 0.48 / 0.32 / 0.02 / 0.00 | 1.5e-01 |
| ex3of8 | 102 | 1355 | -3.73 | 0.30 / 0.00 / 0.00 / 0.00 ; 0.29 / 0.27 / 0.17 / 0.00 | 1.6e-01 |
| band11 | 891 | 3253 | -1.87 | 0.49 / 0.49 / 0.00 / 0.00 ; 0.50 / 0.50 / 0.47 / 0.01 | 1.5e-01 |
| far9 | 92 | 392 | -2.09 | 0.20 / 0.01 / 0.00 / 0.00 ; 0.23 / 0.14 / 0.05 / 0.00 | 1.5e-01 |
| ssym9 | 111 | 821 | -2.89 | 0.48 / 0.00 / 0.00 / 0.00 ; 0.47 / 0.33 / 0.05 / 0.00 | 1.6e-01 |
| symxpar | 112 | 2176 | -4.28 | 0.51 / 0.00 / 0.00 / 0.00 ; 0.49 / 0.41 / 0.28 / 0.00 | 1.4e-01 |
| twosym | 445 | 3389 | -2.93 | 0.50 / 0.50 / 0.00 / 0.00 ; 0.49 / 0.49 / 0.45 / 0.01 | 1.6e-01 |
| thrsum | 77 | 515 | -2.74 | 0.10 / 0.00 / 0.00 / 0.00 ; 0.42 / 0.19 / 0.05 / 0.00 | 1.5e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 4 of 88 (ex3of8@16: 0.26 vs 0.24; ex3of8@32: 0.33 vs 0.28; far9@16: 0.38 vs 0.26; symxpar@64: 0.51 vs 0.49). Of these, by more than 2 standard errors of the seed-to-seed spread: 0.

Mean log2 ratio over targets where both learn: -2.89 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 8; clearly worse: 0; of 8. Largest compute used: 1.6e-01 of a GD run.

