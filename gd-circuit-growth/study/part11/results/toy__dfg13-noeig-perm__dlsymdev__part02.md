## dfg13-noeig-perm on the dlsymdev suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| ssym9 | 111 | 821 | -2.89 | 0.49 / 0.00 / 0.00 / 0.00 ; 0.47 / 0.33 / 0.05 / 0.00 | 1.6e-01 |
| symxpar | 112 | 2176 | -4.28 | 0.51 / 0.00 / 0.00 / 0.00 ; 0.49 / 0.41 / 0.28 / 0.00 | 1.4e-01 |
| twosym | 447 | 3389 | -2.92 | 0.50 / 0.51 / 0.00 / 0.00 ; 0.49 / 0.49 / 0.45 / 0.01 | 1.6e-01 |
| thrsum | 112 | 515 | -2.20 | 0.11 / 0.00 / 0.00 / 0.00 ; 0.42 / 0.19 / 0.05 / 0.00 | 1.5e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 1 of 44 (symxpar@64: 0.51 vs 0.49). Of these, by more than 2 standard errors of the seed-to-seed spread: 1 (symxpar@64).

Mean log2 ratio over targets where both learn: -3.07 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 4; clearly worse: 0; of 4. Largest compute used: 1.6e-01 of a GD run.

