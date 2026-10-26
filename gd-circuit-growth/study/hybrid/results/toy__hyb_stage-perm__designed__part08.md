## hyb_stage-perm on the designed suite (d = 30)

| target | n* learner | n* networks | log2 ratio (learner/networks) | test error at n = 64 / 256 / 1024 / 4096 (learner; networks) | max FLOPs / GD run |
|---|---|---|---|---|---|
| sparsepoly | 92 | 2205 | -4.58 | 0.16 / 0.00 / 0.00 / 0.00 ; 0.24 / 0.15 / 0.13 / 0.00 | 7.6e-02 |
| rand0 | 57 | 222 | -1.96 | 0.04 / 0.03 / 0.00 / 0.00 ; 0.43 / 0.05 / 0.00 / 0.00 | 8.8e-02 |

Cells (target, n) where the learner's seed-mean test error exceeds the networks' by more than 0.02: 1 of 22 (rand0@16: 0.51 vs 0.48). Of these, by more than 2 standard errors of the seed-to-seed spread: 0.

Mean log2 ratio over targets where both learn: -3.27 (negative = learner needs less data). Learner clearly better (ratio < -0.25 or networks never): 2; clearly worse: 0; of 2. Largest compute used: 8.8e-02 of a GD run.

