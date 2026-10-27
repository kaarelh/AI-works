## p10_sum-perm on the dlsymdev suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| ssym9 | 104 | 821 | -2.99 | 0.33 / 0.00 / 0.00 / 0.00 ; 0.47 / 0.33 / 0.05 / 0.00 | 2.3e-01 |
| symxpar | 111 | 2176 | -4.29 | 0.50 / 0.00 / 0.00 / 0.00 ; 0.49 / 0.41 / 0.28 / 0.00 | 2.0e-01 |
| twosym | 415 | 3389 | -3.03 | 0.49 / 0.33 / 0.00 / 0.00 ; 0.49 / 0.49 / 0.45 / 0.01 | 2.4e-01 |
| thrsum | 80 | 515 | -2.69 | 0.12 / 0.00 / 0.00 / 0.00 ; 0.42 / 0.19 / 0.05 / 0.00 | 2.1e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 1 of 44 (thrsum@16: 0.47 vs 0.45). Of these, by more than 2 standard errors of the seed-to-seed spread: 0.

Mean log2 ratio over targets where both learn: -3.25 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 4; clearly worse: 0; of 4. Largest compute used: 2.4e-01 of a GD run.

