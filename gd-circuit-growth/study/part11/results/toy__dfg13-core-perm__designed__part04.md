## dfg13-core-perm on the designed suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| dnf3 | 195 | 505 | -1.37 | 0.34 / 0.00 / 0.00 / 0.00 ; 0.30 / 0.17 / 0.02 / 0.00 | 1.6e-02 |
| dlist5 | 52 | 110 | -1.10 | 0.03 / 0.02 / 0.00 / 0.00 ; 0.16 / 0.05 / 0.01 / 0.00 | 1.2e-02 |
| rmaj9 | 209 | 2027 | -3.28 | 0.43 / 0.00 / 0.00 / 0.00 ; 0.25 / 0.20 / 0.16 / 0.00 | 1.3e-02 |
| andxor | 44 | 376 | -3.10 | 0.00 / 0.00 / 0.00 / 0.00 ; 0.33 / 0.19 / 0.00 / 0.00 | 7.0e-03 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 6 of 44 (dnf3@64: 0.34 vs 0.30; dlist5@16: 0.35 vs 0.31; rmaj9@16: 0.50 vs 0.40; rmaj9@32: 0.50 vs 0.32; rmaj9@64: 0.43 vs 0.25; rmaj9@128: 0.34 vs 0.20). Of these, by more than 2 standard errors of the seed-to-seed spread: 6 (dnf3@64, dlist5@16, rmaj9@16, rmaj9@32, rmaj9@64, rmaj9@128).

Mean log2 ratio over targets where both learn: -2.21 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 4; clearly worse: 0; of 4. Largest compute used: 1.6e-02 of a GD run.

