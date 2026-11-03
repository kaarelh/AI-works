## dfg13-K3-perm on the dlsymdev suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| sym7 | 55 | 670 | -3.59 | 0.00 / 0.00 / 0.00 / 0.00 ; 0.48 / 0.32 / 0.02 / 0.00 | 9.6e-03 |
| ex3of8 | 102 | 1355 | -3.73 | 0.30 / 0.00 / 0.00 / 0.00 ; 0.29 / 0.27 / 0.17 / 0.00 | 2.5e-02 |
| band11 | 891 | 3253 | -1.87 | 0.49 / 0.49 / 0.00 / 0.00 ; 0.50 / 0.50 / 0.47 / 0.01 | 9.1e-03 |
| far9 | 92 | 392 | -2.09 | 0.20 / 0.01 / 0.00 / 0.00 ; 0.23 / 0.14 / 0.05 / 0.00 | 1.3e-02 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 3 of 44 (ex3of8@16: 0.26 vs 0.24; ex3of8@32: 0.33 vs 0.28; far9@16: 0.38 vs 0.26). Of these, by more than 2 standard errors of the seed-to-seed spread: 0.

Mean log2 ratio over targets where both learn: -2.82 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 4; clearly worse: 0; of 4. Largest compute used: 2.5e-02 of a GD run.

