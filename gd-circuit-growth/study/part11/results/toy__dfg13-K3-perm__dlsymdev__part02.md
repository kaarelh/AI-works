## dfg13-K3-perm on the dlsymdev suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| ssym9 | 111 | 821 | -2.89 | 0.48 / 0.00 / 0.00 / 0.00 ; 0.47 / 0.33 / 0.05 / 0.00 | 1.6e-02 |
| symxpar | 112 | 2176 | -4.28 | 0.51 / 0.00 / 0.00 / 0.00 ; 0.49 / 0.41 / 0.28 / 0.00 | 2.3e-02 |
| twosym | 445 | 3389 | -2.93 | 0.50 / 0.50 / 0.00 / 0.00 ; 0.49 / 0.49 / 0.45 / 0.01 | 1.3e-02 |
| thrsum | 77 | 515 | -2.74 | 0.10 / 0.00 / 0.00 / 0.00 ; 0.42 / 0.19 / 0.05 / 0.00 | 1.1e-02 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 1 of 44 (symxpar@64: 0.51 vs 0.49). Of these, by more than 2 standard errors of the seed-to-seed spread: 0.

Mean log2 ratio over targets where both learn: -3.21 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 4; clearly worse: 0; of 4. Largest compute used: 2.3e-02 of a GD run.

