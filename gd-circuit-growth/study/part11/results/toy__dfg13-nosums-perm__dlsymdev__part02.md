## dfg13-nosums-perm on the dlsymdev suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| ssym9 | 1197 | 821 | +0.54 | 0.49 / 0.29 / 0.12 / 0.00 ; 0.47 / 0.33 / 0.05 / 0.00 | 4.0e-01 |
| symxpar | 311 | 2176 | -2.81 | 0.51 / 0.14 / 0.00 / 0.00 ; 0.49 / 0.41 / 0.28 / 0.00 | 1.4e-01 |
| twosym | 3466 | 3389 | +0.03 | 0.50 / 0.51 / 0.50 / 0.00 ; 0.49 / 0.49 / 0.45 / 0.01 | 4.0e-01 |
| thrsum | 71 | 515 | -2.86 | 0.10 / 0.00 / 0.00 / 0.00 ; 0.42 / 0.19 / 0.05 / 0.00 | 1.4e-01 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 6 of 44 (ssym9@128: 0.50 vs 0.44; ssym9@1024: 0.12 vs 0.05; ssym9@2048: 0.03 vs 0.00; symxpar@64: 0.51 vs 0.49; twosym@1024: 0.50 vs 0.45; twosym@2048: 0.42 vs 0.35). Of these, by more than 2 standard errors of the seed-to-seed spread: 4 (ssym9@128, ssym9@1024, symxpar@64, twosym@1024).

Mean log2 ratio over targets where both learn: -1.27 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 2; clearly worse: 1; of 4. Largest compute used: 4.0e-01 of a GD run.

